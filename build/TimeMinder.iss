[Setup]
AppName=TimeMinder
AppVersion=1.0
DefaultDirName={pf}\TimeMinder
DefaultGroupName=TimeMinder
OutputDir=..
OutputBaseFilename=TimeMinderSetup
Compression=lzma
SolidCompression=yes

[Files]
Source: "../TimeMinder.exe"; DestDir: "{app}"
Source: "../images/*"; DestDir: "{app}/images"; Flags: recursesubdirs createallsubdirs
Source: "../sounds/*"; DestDir: "{app}/sounds"; Flags: recursesubdirs createallsubdirs
Source: "../README.md"; DestDir: "{app}"

[Icons]
Name: "{group}\TimeMinder"; Filename: "{app}\TimeMinder.exe"
Name: "{userdesktop}\TimeMinder"; Filename: "{app}\TimeMinder.exe"; Tasks: desktopicon

[Tasks]
Name: "desktopicon"; Description: "Create a &desktop icon"; GroupDescription: "Additional icons:"

[Run]
Filename: "{app}\TimeMinder.exe"; Description: "Launch TimeMinder"; Flags: nowait postinstall skipifsilent