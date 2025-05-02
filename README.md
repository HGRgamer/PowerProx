# PowerProx
Tired of constantly logging in to your college proxy and switching it on/off every so often?

**PowerProx** is here. It's a lightweight Windows system tray utility built with PowerShell that lets you easily toggle proxy settings, auto-login to proxy servers, and manage proxy credentials. It’s especially useful for environments where proxies require periodic authentication or LDAP-based login.

Download and Get It Running in Sec's Using The Installer: https://github.com/HGRgamer/PowerProx/releases/latest

---

## 🚀 Features

- 🌐 **Proxy Toggle**: Enable/disable Windows proxy with a single click.
- 🔐 **Secure Auto-Login**: Periodically authenticates to proxies using securely stored credentials.
- 🕓 **Custom Retry Interval**: Configure how frequently login attempts are retried.
- 📁 **Configurable Settings GUI**: Change credentials, toggle auto-login, and set retry intervals via a simple GUI.
- 🔑 **Credential Management**: Secure storage using Windows Credential Manager.
- 🖥️ **Single Instance Protection**: Prevents multiple app instances from running.
- 🔄 **Startup Option**: Can be configured to start with Windows.
- 📦 **Installer**: Bundled with an Inno Setup installer for easy distribution.

---

## 🧰 Requirements

- Windows 10/11
- PowerShell 5.1+
- .NET Framework (typically preinstalled)

---

## ⚙️ How to Use

### 🖥️ Installation

1. Download and run the latest `PowerProxInstaller.exe` from the [Releases](#) section.
2. Configure whether to:
   - Auto-start PowerProx with Windows
   - Create a Desktop Shortcut
   - Create Start Menu Shortcut
3. Launch the app after installation.

PowerProx will appear in the system tray with status icons. (You can drag it onto your taskbar if needed)

<img src="https://static1.makeuseofimages.com/wordpress/wp-content/uploads/2023/05/hidden-icons-menu-windows-11.jpg" width="400" height="200">

---

### 🧪 Configuring Settings

1. Right-click the tray icon and go to **Settings**.
2. Enter:
   - Your proxy credentials (username and password)
   - Enable/disable auto-login
   - Set retry interval (in seconds)
3. Save and close. You're ready to go!

Imp: Keep retry interval at least 10secs to avoid overloading server or excessive usage.  

---

## 🧼 Uninstall Instructions (If installed via the installer):
- Go to **Control Panel > Programs > Uninstall a program**, find **PowerProx**, and click **Uninstall**.
- The uninstaller will automatically stop the app (if running) and remove all installed files.

---

## 🛠 Configuration File

PowerProx stores settings in `config.json` located in AppData:

```json
{
  "retryInterval": 30,
  "autoLogin": true
}
```

You can edit this file manually or through the settings UI.

## 📷 Screenshots
  Icon:
  <div>
    <img src="https://raw.githubusercontent.com/HGRgamer/PowerProx/refs/heads/main/proxy_off.ico" width="128" height="128">
    <img src="https://raw.githubusercontent.com/HGRgamer/PowerProx/refs/heads/main/proxy_on.ico" width="128" height="128">
  </div>
  
  Settings:
  
  <img src="https://github.com/user-attachments/assets/79c2c847-2f32-43b4-9a52-498c749182f5">  
  
  Menu:
  
  <img src="https://github.com/user-attachments/assets/d32ed8ed-c772-4209-a169-c6f44de1cf29">  

---

## Credits
- <img src="https://raw.githubusercontent.com/HGRgamer/PowerProx/refs/heads/main/proxyicon.ico" width="16" height="16"> [Proxy icon](https://www.flaticon.com/free-icons/proxy) created by [Uniconlabs](https://www.flaticon.com/authors/uniconlabs) - Flaticon  
- <img src="https://raw.githubusercontent.com/HGRgamer/PowerProx/refs/heads/main/proxy_on.ico" width="16" height="16"> [On icon](https://www.flaticon.com/free-icons/on) created by [Pixel perfect](https://www.flaticon.com/authors/pixel-perfect) - Flaticon
- <img src="https://raw.githubusercontent.com/HGRgamer/PowerProx/refs/heads/main/proxy_off.ico" width="16" height="16"> [Off icon](https://www.flaticon.com/free-icons/off) created by [Pixel perfect](https://www.flaticon.com/authors/pixel-perfect) - Flaticon
