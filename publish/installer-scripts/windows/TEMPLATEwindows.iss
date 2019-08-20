#define MyAppName "Commonwealth Robotics BowlerStudio"
#define MyAppSlug "bowlerstudio"
#define MyAppPublisher "Commonwealth Robotics"
#define MyAppURL "http://www.commonwealthrobotics.com"
#define MyAppOutput "C:\archive\VER"

#define MyAppVersion "VER"
#define MyAppVerName "Commonwealth Robotics BowlerStudio VER"

#define MyAppPath "C:\installer-scripts\windows\BowlerStudioApp"
#define MyLicensePath "C:\installer-scripts\windows\"

;#define MyAppPath "G:\installer-scripts\windows\BowlerStudioApp"
;#define MyLicensePath "G:\installer-scripts\windows\"

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
Name: {group}\BowlerStudio; Filename: {app}\BowlerStudioApp\BowlerStudio.vbs 
Name: {group}\{#MyAppVerName}; Filename: {app}\BowlerStudioApp\
Name: {commondesktop}\BowlerStudio; Filename: {app}\BowlerStudioApp\BowlerStudio.vbs; WorkingDir: {app}\BowlerStudioApp\; Comment: "Commonwealth Robotics BowlerStudio";IconFilename: {app}\BowlerStudioApp\splash.ico;


[Code]

// Utility functions for Inno Setup
//   used to add/remove programs from the windows firewall rules
// Code originally from http://news.jrsoftware.org/news/innosetup/msg43799.html
// https://www.activexperts.com/admin/vbscript-collection/networking/windowsfirewall/

procedure setfirewallexception(appname,filename:string);
var
  firewallobject: variant;
  firewallmanager: variant;
  firewallprofile: variant;
  objPolicy:       variant;
  objProfile:      variant;
begin
  try
    firewallobject := createoleobject('hnetcfg.fwauthorizedapplication');
    firewallobject.processimagefilename := filename;
    firewallobject.name := appname;
    firewallobject.scope := 0;
    firewallobject.ipversion := 2;
    firewallobject.enabled := true;
    firewallmanager := createoleobject('hnetcfg.fwmgr');
    objPolicy := firewallmanager.LocalPolicy
    objProfile := objPolicy.GetProfileByType(1)

    firewallprofile := firewallmanager.localpolicy.currentprofile;
    firewallprofile.authorizedapplications.add(firewallobject);
    objProfile.AuthorizedApplications.Add(firewallobject);
    
  except
  end;
end;


procedure RemoveFirewallException( FileName:string );
var
  FirewallManager: Variant;
  FirewallProfile: Variant;
begin
  try
    FirewallManager := CreateOleObject('HNetCfg.FwMgr');
    FirewallProfile := FirewallManager.LocalPolicy.CurrentProfile;
    FireWallProfile.AuthorizedApplications.Remove(FileName);
  except
  end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep=ssPostInstall then
     SetFirewallException('BowlerStudioBAT', ExpandConstant('{app}\')+'\BowlerStudioApp\BowlerStudio.vbs');  
if CurStep=ssPostInstall then
     SetFirewallException('BowlerStudioBAT', ExpandConstant('{app}\')+'\BowlerStudioApp\BowlerStudio.bat');
 if CurStep=ssPostInstall then
     SetFirewallException('BowlerStudioEXE', ExpandConstant('{app}\')+'\BowlerStudioApp\BowlerStudio.exe');
  if CurStep=ssPostInstall then 
     SetFirewallException('BowlerStudioJAVA', ExpandConstant('{app}\')+'\BowlerStudioApp\jre\bin\java.exe');
  if CurStep=ssPostInstall then 
     SetFirewallException('BowlerStudioJAVAW', ExpandConstant('{app}\')+'\BowlerStudioApp\jre\bin\javaw.exe');
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
  if CurUninstallStep=usPostUninstall then
     RemoveFirewallException( ExpandConstant('{app}\')+'\BowlerStudioApp\BowlerStudio.vbs');
  if CurUninstallStep=usPostUninstall then
     RemoveFirewallException( ExpandConstant('{app}\')+'\BowlerStudioApp\BowlerStudio.bat');
  if CurUninstallStep=usPostUninstall then
     RemoveFirewallException( ExpandConstant('{app}\')+'\BowlerStudioApp\BowlerStudio.exe');
  if CurUninstallStep=usPostUninstall then 
     RemoveFirewallException( ExpandConstant('{app}\')+'\BowlerStudioApp\jre\bin\java.exe');
  if CurUninstallStep=usPostUninstall then 
     RemoveFirewallException( ExpandConstant('{app}\')+'\BowlerStudioApp\jre\bin\javaw.exe');
end;

