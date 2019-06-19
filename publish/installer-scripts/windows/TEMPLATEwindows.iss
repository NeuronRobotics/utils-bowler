#define MyAppName "Commonwealth Robotics BowlerStudio"
#define MyAppSlug "bowlerstudio"
#define MyAppPublisher "Commonwealth Robotics"
#define MyAppURL "http://www.commonwealthrobotics.com"
#define MyAppOutput "C:\archive\VER"

#define MyAppVersion "VER"
#define MyAppVerName "Commonwealth Robotics BowlerStudio VER"
#define MyAppPath "C:\installer-scripts\windows\BowlerStudioApp"
#define MyLicensePath "C:\installer-scripts\windows\"

[Setup]
AppId={{A6FF93DE-2451-4610-8C9B-64DC2546DBE7}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppVerName}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={pf}\{#MyAppName}
DefaultGroupName={#MyAppName}
LicenseFile={#MyLicensePath}\LICENSE.txt
OutputDir={#MyAppOutput}
OutputBaseFilename=Windows-64-BowlerStudio-{#MyAppVersion}
Compression=lzma
SolidCompression=yes
; Tell Windows Explorer to reload the environment
ChangesEnvironment=yes

[Languages]
Name: english; MessagesFile: compiler:Default.isl


[Files]
Source: {#MyAppPath}\*; DestDir: {app}\BowlerStudioApp; Flags: recursesubdirs createallsubdirs; Languages: ; Excludes: .* 


[Icons]
Name: {group}\BowlerStudio; Filename: {app}\BowlerStudioApp\BowlerStudio.exe 
Name: {group}\{#MyAppVerName}; Filename: {app}\BowlerStudioApp\
Name: {commondesktop}\BowlerStudio; Filename: {app}\BowlerStudioApp\BowlerStudio.exe; WorkingDir: {app}\BowlerStudioApp\; Comment: "Commonwealth Robotics BowlerStudio";IconFilename: {app}\BowlerStudioApp\splash.ico;
