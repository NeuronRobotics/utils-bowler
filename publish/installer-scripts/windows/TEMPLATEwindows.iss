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

// utility functions for inno setup
//   used to add/remove programs from the windows firewall rules
// code originally from http://news.jrsoftware.org/news/innosetup/msg43799.html
procedure setfirewallexceptionLocal(appname,filename:string);
var
  objApplication: variant;
  objFirewall: variant;
  objPolicyLocal: variant;
	objProfile: variant;
	colApplications: variant; 
	objPolicy: variant;
begin
  try
    objApplication := createoleobject('hnetcfg.fwauthorizedapplication');
    objApplication.processimagefilename := filename;
    objApplication.name := appname;
    objApplication.scope := 0;
    objApplication.ipversion := 2;
    objApplication.enabled := true;
    objFirewall := createoleobject('hnetcfg.fwmgr');
    //objFirewall.LocalPolicy.objPolicyLocal.GetProfileByType(1).AuthorizedApplications.Add(objApplication);
    objPolicyLocal := objFirewall.localpolicy.currentprofile;
    objPolicyLocal.authorizedapplications.add(objApplication);
   except
  end;
end;

// utility functions for inno setup
//   used to add/remove programs from the windows firewall rules
// code originally from http://news.jrsoftware.org/news/innosetup/msg43799.html
procedure setfirewallexception(appname,filename:string);
var
  objApplication: variant;
  objFirewall: variant;
  objPolicyLocal: variant;
	objProfile: variant;
	colApplications: variant; 
	objPolicy: variant;
begin
  try
    objApplication := createoleobject('hnetcfg.fwauthorizedapplication');
    objApplication.processimagefilename := filename;
    objApplication.name := appname;
    objApplication.scope := 0;
    objApplication.ipversion := 2;
    objApplication.enabled := true;
    objFirewall := createoleobject('hnetcfg.fwmgr');
		objPolicy := objFirewall.LocalPolicy ;
    objProfile := objPolicy.GetProfileByType(1) ;
		colApplications := objProfile.AuthorizedApplications ;
		colApplications.Add(objApplication) ;
    setfirewallexceptionLocal(appname,filename);
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

