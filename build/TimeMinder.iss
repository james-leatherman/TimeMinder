#define SourcePath ".."

[Setup]
AppName=TimeMinder
AppVersion=1.0.2
DefaultDirName={pf}\TimeMinder
DefaultGroupName=TimeMinder
OutputDir=..
OutputBaseFilename=TimeMinderSetup
Compression=lzma
SolidCompression=yes

[Files]
Source: "{#SourcePath}\TimeMinder.exe"; DestDir: "{app}"
Source: "{#SourcePath}\images\*"; DestDir: "{app}\images"; Flags: recursesubdirs createallsubdirs
Source: "{#SourcePath}\sounds\*"; DestDir: "{app}\sounds"; Flags: recursesubdirs createallsubdirs
Source: "{#SourcePath}\README.md"; DestDir: "{app}"

[Icons]
Name: "{group}\TimeMinder"; Filename: "{app}\TimeMinder.exe"
Name: "{userdesktop}\TimeMinder"; Filename: "{app}\TimeMinder.exe"; Tasks: desktopicon

[Tasks]
Name: "desktopicon"; Description: "Create a &desktop icon"; GroupDescription: "Additional icons:"

[Run]
Filename: "cmd.exe"; Parameters: "/C attrib -R ""{app}\\*.*"" /S /D"; Flags: runhidden
Filename: "{app}\TimeMinder.exe"; Description: "Launch TimeMinder"; Flags: nowait postinstall skipifsilent

[UninstallDelete]
Type: filesandordirs; Name: "{userappdata}\\TimeMinder"