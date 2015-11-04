#define MyAppName "Neuron Robotics DyIO Drivers"
#define MyAppVersion "1.0.1"
#define MyAppSlug "dyio-drivers"
#define MyAppVerName "Neuron Robotics Device Drivers"
#define MyAppPublisher "Neuron Robotics, LLC"
#define MyAppURL "http://www.neuronrobotics.com"
#define MyAppOutput "T:\archive\"
#define MyAppPath ".\driver"

[Files]
Source: {#MyAppPath}\*; DestDir: {win}\inf; Excludes: .*

[Setup]
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppVerName}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
LicenseFile={#MyAppPath}\LICENSE.txt
OutputDir={#MyAppOutput}
OutputBaseFilename={#MyAppSlug}-{#MyAppVersion}
Compression=lzma
SolidCompression=yes
CreateAppDir=false
