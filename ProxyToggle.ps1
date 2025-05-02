######### Check For Single Instance #########

Add-Type -TypeDefinition @"
using System;
using System.Threading;
public class SingleInstance {
    private static Mutex mutex;
    public static bool IsSingleInstance(string name) {
        bool createdNew;
        mutex = new Mutex(true, name, out createdNew);
        return createdNew;
    }
}
"@

if (-not [SingleInstance]::IsSingleInstance("PowerProx_Mutex")) {
    [void][System.Windows.Forms.MessageBox]::Show("PowerProx is already running.", "Duplicate Instance", "OK", "Warning")
    [Environment]::Exit(0)
}

######### Init #########

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

[System.Windows.Forms.Application]::SetCompatibleTextRenderingDefault($false)
[System.Windows.Forms.Application]::EnableVisualStyles()

$ProgressPreference = 'SilentlyContinue'

$proxyRegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings"

#icons paths
$exeDir = $null

if ($MyInvocation.MyCommand.CommandType -eq "ExternalScript")
 { $exeDir = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition }
 else
 { $exeDir = Split-Path -Parent -Path ([Environment]::GetCommandLineArgs()[0]) 
     if (!$exeDir){ $exeDir = "." } }

$iconOn = Join-Path $exeDir "proxy_on.ico"
$iconOff = Join-Path $exeDir "proxy_off.ico"

if (-not (Test-Path $iconOn) -or -not (Test-Path $iconOff)) {
    [System.Windows.Forms.MessageBox]::Show("Missing icon files.", "Error", "OK", "Error")
    exit
}

$notifyIcon = New-Object System.Windows.Forms.NotifyIcon
$notifyIcon.Visible = $true

$modulePath = Join-Path -Path $exeDir -ChildPath "CredentialManager"
if (-not (Get-Module -ListAvailable -Name CredentialManager)) {
    Import-Module $modulePath
}

######### Config #########

$appDir = Join-Path -Path $env:APPDATA -ChildPath "PowerProx"
if (-not (Test-Path $appDir)) {
    New-Item -ItemType Directory -Path $appDir -Force | Out-Null
}

$configPath = Join-Path -Path $appDir -ChildPath "config.json"
function Get-Config {
    if (Test-Path $configPath) {
        return Get-Content $configPath | ConvertFrom-Json
    } else {
        return @{ retryInterval = 10; autoLogin = $true }
    }
}
$config = Get-Config

function Verify-And-FixConfig {
    if ($config.retryInterval -le 0) {
        $config.retryInterval = 10
    }

    if (-not ($config.autoLogin -is [bool])) {
        $config.autoLogin = $true
    }
}
Verify-And-FixConfig

function Save-Config {
    Verify-And-FixConfig
    if ($config -ne $null) {
        $json = $config | ConvertTo-Json -Depth 3
        $json | Set-Content -Path $configPath -Encoding UTF8
    }
}

######### Credentials #########

function Save-Credentials {
    param (
        [string]$username,
        [string]$password
    )
    if ([string]::IsNullOrEmpty($username) -or [string]::IsNullOrEmpty($password)) {
        Remove-StoredCredential -Target "PowerProx" -ErrorAction SilentlyContinue
        return
    }

    New-StoredCredential -Target "PowerProx" -UserName $username -Password $password -Persist LocalMachine | Out-Null
}

function Get-Credentials {
    $cred = Get-StoredCredential -Target "PowerProx"
    if ($cred) {
        return @($cred.UserName, $cred.GetNetworkCredential().Password )
    } else {
        return @("", "")
    }
}

function LoginProxy {
    param([bool]$showPopup = $true, [bool]$showExtraPopups = $false)

    $testUrl = "http://connectivitycheck.gstatic.com/generate_204"
    $cred = Get-Credentials
    $username = $cred[0]
    $password = $cred[1]

    if ((-not $username -or -not $password)) {
        if($showPopup -and $showExtraPopups){
            [System.Windows.Forms.MessageBox]::Show("Username Or Password is not set", "AutoLogin: Failed!", "OK", "Information")
        }
        return
    }

    $pair = "$username`:$password"
    $bytes = [System.Text.Encoding]::ASCII.GetBytes($pair)
    $base64 = [Convert]::ToBase64String($bytes)
    $headers = @{"Authorization" = "Basic $base64"}

    try {
        $initResponse = Invoke-WebRequest -Uri "$testUrl" -MaximumRedirection 0 -UseBasicParsing -TimeoutSec 1 -ErrorAction Stop 
        if ($initResponse.StatusCode -eq 307) {
            $loginUrl = $initResponse.Headers["Location"] -replace "^https://", "http://"
            $response = Invoke-WebRequest -Uri "$loginUrl"  -Headers $headers -UseBasicParsing -TimeoutSec 1 -ErrorAction Stop
            [System.Windows.Forms.MessageBox]::Show("User was successfully Authenticated", "AutoLogin: Success!", "OK", "Information")
        } elseif ($initResponse.StatusCode -eq 204 -and $showPopup) {
            [System.Windows.Forms.MessageBox]::Show("User is already Authenticated", "AutoLogin", "OK", "Information")
        }
    } catch {
        $statusCode = $_.Exception.Response.StatusCode
        if($statusCode -eq 401 -and $showPopup){
            [System.Windows.Forms.MessageBox]::Show("Invalid Username Or Password", "AutoLogin: Failed!", "OK", "Information")
        }
    }
}

$proxyEnabled = Get-ItemProperty -Path $proxyRegPath -Name ProxyEnable | Select-Object -ExpandProperty ProxyEnable
$authTimer = New-Object System.Windows.Forms.Timer
$authTimer.Interval = $config.retryInterval * 1000
$authTimer.Add_Tick({
    if ($config.autoLogin -and $proxyEnabled) {
        LoginProxy $false
    }
})
$authTimer.Start()

######### Forms #########

function Settings-Menu {
    $cred = Get-Credentials
    $storedUsername = $cred[0]
    $storedPassword = $cred[1]

    $form = New-Object Windows.Forms.Form
    $form.Text = "Proxy Settings"
    $form.Size = New-Object Drawing.Size(320, 220)
    $form.StartPosition = "CenterScreen"
    $form.FormBorderStyle = "FixedDialog"
    $form.MaximizeBox = $false
    $form.MinimizeBox = $false
    $form.TopMost = $true
    $form.AutoScaleMode = "Font"

    $labelUser = New-Object Windows.Forms.Label
    $labelUser.Text = "Username:"
    $labelUser.Location = New-Object Drawing.Point(20, 20)
    $labelUser.AutoSize = $true
    $form.Controls.Add($labelUser)

    $textBoxUser = New-Object Windows.Forms.TextBox
    $textBoxUser.Location = New-Object Drawing.Point(120, 18)
    $textBoxUser.Size = New-Object Drawing.Size(160, 25)
    $textBoxUser.Text = "$storedUsername"
    $textBoxUser.TextAlign = [System.Windows.Forms.HorizontalAlignment]::Left
    $form.Controls.Add($textBoxUser)

    $labelPass = New-Object Windows.Forms.Label
    $labelPass.Text = "Password:"
    $labelPass.Location = New-Object Drawing.Point(20, 60)
    $labelPass.AutoSize = $true
    $form.Controls.Add($labelPass)

    $textBoxPass = New-Object Windows.Forms.TextBox
    $textBoxPass.Location = New-Object Drawing.Point(120, 58)
    $textBoxPass.Size = New-Object Drawing.Size(160, 25)
    $textBoxPass.Text = "$storedPassword"
    $textBoxPass.PasswordChar = '*'
    $textBoxPass.TextAlign = [System.Windows.Forms.HorizontalAlignment]::Left
    $form.Controls.Add($textBoxPass)

    $labelRetry = New-Object Windows.Forms.Label
    $labelRetry.Text = "Autologin Retry Interval (s):"
    $labelRetry.Location = New-Object Drawing.Point(20, 100)
    $labelRetry.AutoSize = $true
    $form.Controls.Add($labelRetry)

    $textBoxRetry = New-Object Windows.Forms.TextBox
    $textBoxRetry.Location = New-Object Drawing.Point(160, 98)
    $textBoxRetry.Size = New-Object Drawing.Size(120, 25)
    $textBoxRetry.text = $config.retryInterval
    $form.Controls.Add($textBoxRetry)

    $checkBoxAutoLogin = New-Object Windows.Forms.CheckBox
    $checkBoxAutoLogin.Text = "Auto Login"
    $checkBoxAutoLogin.Location = New-Object Drawing.Point(40, 130)
    $checkBoxAutoLogin.AutoSize = $true
    $checkBoxAutoLogin.Checked = $config.autoLogin
    $form.Controls.Add($checkBoxAutoLogin)

    $saveButton = New-Object Windows.Forms.Button
    $saveButton.Text = "Save"
    $saveButton.Location = New-Object Drawing.Point(120, 150)
    $saveButton.Size = New-Object Drawing.Size(90, 30)
    $saveButton.Add_Click({
        $username = $textBoxUser.Text.Trim()
        $password = $textBoxPass.Text.Trim()

        Save-Credentials $username $password
        
        $config.retryInterval = [int]$textBoxRetry.Text
        $config.autoLogin = $checkboxAutoLogin.Checked
        Save-Config
        $authTimer.Interval = $config.retryInterval * 1000

        [System.Windows.Forms.MessageBox]::Show("Settings Updated Successfully!", "Success", "OK", "Information")

        $form.Close()
    })
    $form.Controls.Add($saveButton)

    $cancelButton = New-Object Windows.Forms.Button
    $cancelButton.Text = "Cancel"
    $cancelButton.Location = New-Object Drawing.Point(210, 150)
    $cancelButton.Size = New-Object Drawing.Size(90, 30)
    $cancelButton.Add_Click({ $form.Close() })
    $form.Controls.Add($cancelButton)

    $form.ShowDialog()
}

function Update-ProxyStatus {
    $proxyEnabled = Get-ItemProperty -Path $proxyRegPath -Name ProxyEnable | Select-Object -ExpandProperty ProxyEnable
    if ($proxyEnabled -eq 1) {
        $notifyIcon.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($iconOn)
        $notifyIcon.Text = "Proxy: Enabled"
    } else {
        $notifyIcon.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($iconOff)
        $notifyIcon.Text = "Proxy: Disabled"
    }
}

function Toggle-Proxy {
    $proxyEnabled = Get-ItemProperty -Path $proxyRegPath -Name ProxyEnable | Select-Object -ExpandProperty ProxyEnable
    if ($proxyEnabled -eq 0) {
        Set-ItemProperty -Path $proxyRegPath -Name ProxyEnable -Value 1
        Update-ProxyStatus #to immediately update icon
	    if ($config.autoLogin) {
            LoginProxy
        }
    } else {
        Set-ItemProperty -Path $proxyRegPath -Name ProxyEnable -Value 0
        Update-ProxyStatus
    }
}

$contextMenu = New-Object System.Windows.Forms.ContextMenuStrip
$toggleMenuItem = $contextMenu.Items.Add("Toggle Proxy")
$authenticateMenuItem = $contextMenu.Items.Add("Authenticate")
$settingsMenuItem = $contextMenu.Items.Add("Settings")
$aboutMenuItem = $contextMenu.Items.Add("About")
$exitMenuItem = $contextMenu.Items.Add("Exit")

$toggleMenuItem.Add_Click({ Toggle-Proxy })
$authenticateMenuItem.Add_Click({ 
    LoginProxy $true $true
})
$settingsMenuItem.Add_Click({ Settings-Menu })

$aboutMenuItem.Add_Click({ 
    [System.Windows.Forms.MessageBox]::Show("Made by Kanav Agrawal.", "PowerProx", "OK", "Information") 
})

$notifyIcon.ContextMenuStrip = $contextMenu
$notifyIcon.Add_MouseClick({ if ($_.Button -eq "Left") { Toggle-Proxy } })

function Stop-App {
    $notifyIcon.Dispose()
    $authTimer.Stop()
    [System.Windows.Forms.Application]::Exit()
    Exit 0
}

Register-EngineEvent PowerShell.Exiting -Action {
    Stop-App
} | Out-Null

$exitMenuItem.Add_Click({
    Stop-App
})
#initial update
Update-ProxyStatus
if ($config.autoLogin -and $proxyEnabled) {
    LoginProxy $false 
}

[System.Windows.Forms.Application]::Run()