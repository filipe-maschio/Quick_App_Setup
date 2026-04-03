# Quick App Setup (Windows)

Automated Windows setup tool using **Batch Script + Winget** to quickly install, verify, and manage essential applications.

## Overview

This project provides a simple yet powerful CLI tool to:

- Install multiple applications in one run;
- Detect already installed apps (skip intelligently);
- Handle installation errors;
- Display clean and colored results;
- Optionally show full Winget logs.

## Built With

- **Windows Batch Script (.bat)**
- **Winget (Windows Package Manager)**

## Features

- Multi-app selection;
- Smart skip (already installed detection);
- Error handling;
- Colored CLI output (✔ ⚠ ✖);
- Optional verbose logging;
- Clean final summary.

## Supported Applications

- Google Chrome
- Tor Browser
- Google Drive
- Mega
- Obsidian
- Anki
- KeePass
- Notepad++
- Foxit PDF
- WinRAR
- PowerToys
- Wireshark

## How to Use

### 1. Download or Clone

```
git clone https://github.com/filipe-maschio/Quick_App_Setup
cd quick-app-setup
```

### 2. Run the Script

```
Quick_App_Setup.bat
```

> ⚠️ Run as **Administrator**

### 3. Select Applications

Example input:

```
1 5 10
```


## Output Example

```
Instalando "Mega"...

✔ Mega instalado

⚠ Google Chrome ja instalado

✖ Google Drive falhou
```

## Final Summary

```
✔ INSTALADOS:
- Mega

⚠ JA EXISTIAM:
- Google Chrome

✖ ERROS:
- Google Drive
```

## Log Modes

You can control installation verbosity:

```
set LOGLEVEL=
```

|Value|Behavior|
|---|---|
|(empty)|Silent mode|
|1|Partial logs|
|2|Full logs|

## Requirements

- Windows 10 / 11
- Winget installed

Check Winget:

```
winget --version
```

## Development Tips

- Remove `--silent` for debugging
- Use full logs (`LOGLEVEL=2`) for troubleshooting
- Test individual installs:

```
winget install --id Google.Chrome -e
```

## Project Structure

```
quick-app-setup/
│
├── Quick_App_Setup.bat
└── README.md
```

## Contributing

Feel free to fork, improve, and submit pull requests.

# 👨‍💻 Author

Developed by **"Fill" Filipe Maschio**

If this project helped you, consider giving it a star ⭐