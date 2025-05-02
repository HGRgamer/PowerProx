[Setup]
AppName=PowerProx
AppVersion=1.0.0
DefaultDirName={localappdata}\PowerProx
DefaultGroupName=PowerProx
UninstallDisplayIcon={app}\PowerProx.exe
OutputBaseFilename=PowerProxInstaller
Compression=lzma
SolidCompression=yes
SetupIconFile="proxyicon.ico"

[Files]
Source: "dist\PowerProx.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "dist\proxy_on.ico"; DestDir: "{app}"; Flags: ignoreversion
Source: "dist\proxy_off.ico"; DestDir: "{app}"; Flags: ignoreversion
Source: "dist\CredentialManager\*"; DestDir: "{app}\CredentialManager"; Flags: ignoreversion recursesubdirs

[Icons]
Name: "{group}\PowerProx"; Filename: "{app}\PowerProx.exe"; IconFilename: "{app}\PowerProx.exe"; Tasks: startmenu
Name: "{commondesktop}\PowerProx"; Filename: "{app}\PowerProx.exe"; IconFilename: "{app}\PowerProx.exe"; Tasks: desktopicon
Name: "{userstartup}\PowerProx"; Filename: "{app}\PowerProx.exe"; Tasks: autostart

[Tasks]
Name: "desktopicon"; Description: "Create a desktop icon"; GroupDescription: "Create shortcuts:"
Name: "startmenu"; Description: "Create a Start Menu shortcut"; GroupDescription: "Create shortcuts:"
Name: "autostart"; Description: "Start PowerProx automatically with Windows"; GroupDescription: "Additional options:"

[Code]
function InitializeSetup(): Boolean;
var
  ResultCode: Integer;
begin
  Exec(ExpandConstant('{cmd}'), '/C taskkill /IM PowerProx.exe /F', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
  Result := True;
end;

[Run]
Filename: "{app}\PowerProx.exe"; Description: "Launch PowerProx"; Flags: nowait postinstall skipifsilent

[UninstallRun]
Filename: "{cmd}"; Parameters: "/C taskkill /IM PowerProx.exe /F"; Flags: runhidden
