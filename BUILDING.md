## 🔧 Building from Source

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/PowerProx.git
cd PowerProx
```

### 2. Compile to EXE

PowerProx is compiled using [`ps2exe`](https://github.com/MScholtes/PS2EXE):

```powershell
Invoke-ps2exe .\ProxyToggle.ps1 .\dist\PowerProx.exe -iconFile .\proxyicon.ico -noConsole -title "PowerProx"
```

Make sure to include the `CredentialManager` directory in your final distribution.

### 3. Create Installer (Optional)

Use [Inno Setup](https://jrsoftware.org/isinfo.php) and the included `ProxyToggleInstaller.iss` script:

1. Open `ProxyToggleInstaller.iss` in Inno Setup.
2. Compile to generate the installer.

---

## ▶️ How to Run (Standalone)

If you don't want to install, just run the compiled PowerProx.exe directly:

```cmd
./PowerProx.exe
```
It will sit in the system tray. Right-click to access options, or hover for current proxy status.

To ensure it runs correctly:

Make sure CredentialManager folder is in the same directory as PowerProx.exe

Run as administrator if your proxy settings require elevated privileges


---
