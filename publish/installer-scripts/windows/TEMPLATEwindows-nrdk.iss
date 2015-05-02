#define MyAppName "Neuron Robotics Development Kit"
#define MyAppSlug "nrdk"
#define JDKREG "SOFTWARE\JavaSoft\Java Development Kit"
#define MyAppPublisher "Neuron Robotics, LLC"
#define MyAppURL "http://www.neuronrobotics.com"
#define MyAppOutput "C:\archive\VER"

#define MyAppVersion "VER"
#define MyAppVerName "Neuron Robotics Development Kit VER"
#define MyAppPath "C:\installer-scripts\windows\nrdk-VER"

#define SystemEnvRegKey "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"
#define CurUserEnvRegKey "Environment"

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
LicenseFile={#MyAppPath}\LICENSE.txt
OutputDir={#MyAppOutput}
OutputBaseFilename={#MyAppSlug}-{#MyAppVersion}
Compression=lzma
SolidCompression=yes
; Tell Windows Explorer to reload the environment
ChangesEnvironment=yes

[Languages]
Name: english; MessagesFile: compiler:Default.isl


[Files]
Source: {#MyAppPath}\*; DestDir: {app}\{#MyAppSlug}-{#MyAppVersion}; Flags: recursesubdirs createallsubdirs; Languages: ; Excludes: .* AfterInstall: setupEnvOpenCV() ;
Source: .\driver\*; DestDir: {app}\{#MyAppSlug}-{#MyAppVersion}\driver; Excludes: .*
Source: .\driver\*; DestDir: {win}\inf; Excludes: .*

[Run]
Filename: {sys}\rundll32.exe; Parameters: "setupapi,InstallHinfSection DefaultInstall 128 {app}\{#MyAppSlug}-{#MyAppVersion}\driver\NRDyIO.inf"; WorkingDir: {app}\{#MyAppSlug}-{#MyAppVersion}\driver\; Flags: 32bit;

[Icons]
Name: {group}\NR Console; Filename: {app}\{#MyAppSlug}-{#MyAppVersion}\bin\BowlerStudio.jar 
Name: {group}\{#MyAppVerName}; Filename: {app}\{#MyAppSlug}-{#MyAppVersion}\
Name: {commondesktop}\NR Console; Filename: {app}\{#MyAppSlug}-{#MyAppVersion}\bin\BowlerStudio.jar; WorkingDir: {app}\{#MyAppSlug}-{#MyAppVersion}\bin\; Comment: "Neuron Robotics BowlerStudio";IconFilename: {app}\{#MyAppSlug}-{#MyAppVersion}\bin\NeuronRobotics.ico;


[Code]
var javaVersion: String;
var isJDK: Boolean;
var JavaHome: String;
var JREBinPath: String;
var JDKBinPath: String;
var IsBoth: Boolean;
var opencvHomeEnvVar :String;



function hasAdminRights(): Boolean;
begin
	if IsAdminLoggedOn() then
	begin
		Result := True;
	end
	else
	begin
		if IsPowerUserLoggedOn() then
		begin
			Result := True;
		end
		else
		begin
			Result := False;
		end
	end
end;


function setupEnvVars(): Boolean;
var javaHomeEnvVar :String;
var sysPath :String;
var idx : Integer;
begin
  
	javaHomeEnvVar:=JavaHome;
	if RegQueryStringValue(HKEY_CURRENT_USER, 'Environment','JavaHome', javaHomeEnvVar) then
	begin
		if (javaHomeEnvVar=JavaHome) then
		begin
	 	 	Result :=True;
	 	end
		else
		begin
	 	 	Result :=False;
	 	end
	end
	else
	begin
		Result :=RegWriteStringValue(HKEY_CURRENT_USER, 'Environment','JavaHome', JavaHome);
	end

	IsBoth := Result
	JREBinPath := JavaHome + '\bin';
	JDKBinPath := javaHomeEnvVar + '\bin';

	if hasAdminRights() then
	begin
    
		if RegQueryStringValue(HKEY_LOCAL_MACHINE, 'SYSTEM\CurrentControlSet\Control\Session Manager\Environment','Path', sysPath) then
		begin
			idx:=Pos(JREBinPath,sysPath);
			if (idx=0) then
			begin
				sysPath:=sysPath + ';' + JREBinPath;
				RegWriteExpandStringValue(HKEY_LOCAL_MACHINE, 'SYSTEM\CurrentControlSet\Control\Session Manager\Environment','Path', sysPath);
			end
		end
		else
		begin
			RegWriteExpandStringValue(HKEY_LOCAL_MACHINE, 'SYSTEM\CurrentControlSet\Control\Session Manager\Environment','Path', JREBinPath);
		end
	end
	else
	begin
		 MsgBox('Because you do not have administration rights, the system path was not updated', mbInformation, MB_OK);
	end
end;

function getJavaVersion(): String;
begin
	if RegQueryStringValue(HKEY_LOCAL_MACHINE, 'SOFTWARE\JavaSoft\Java Development Kit','CurrentVersion', javaVersion) then
	begin
		isJDK:=True;
		RegQueryStringValue(HKEY_LOCAL_MACHINE, 'SOFTWARE\JavaSoft\Java Development Kit\'+javaVersion,'JavaHome', JavaHome)
		Result :=javaVersion;
	end
	else
	begin
		if RegQueryStringValue(HKEY_LOCAL_MACHINE, 'SOFTWARE\JavaSoft\Java Runtime Environment','CurrentVersion', javaVersion) then
		begin
			RegQueryStringValue(HKEY_LOCAL_MACHINE, 'SOFTWARE\JavaSoft\Java Runtime Environment\'+javaVersion,'JavaHome', JavaHome)
      Result :=javaVersion;
		end
		else
		begin
			Result :='0';
		end
	end;
end;



function isJavaVersionOK(): Boolean;
var jv :String;
begin
	jv := getJavaVersion();
	setupEnvVars();
	if (CompareText('1.8', jv)=0) then
	begin
		Result :=True;
	end
	else
	begin
		MsgBox('The version of Java installed is incompatable or missing with {#MyAppName}, Java 8 is required, Reported:'+jv, mbInformation, MB_OK);
		Result :=True;
	end;
end;

function InitializeSetup(): Boolean;
begin
  
	Result :=isJavaVersionOK();
end;

function IsBoth64: Boolean;
begin
	Result := Is64BitInstallMode and IsBoth;
end;

function IsBoth32: Boolean;
begin
	Result := not Is64BitInstallMode and IsBoth;
end;

function GetJDKBin(S: String): String;
begin
	Result :=JDKBinPath;
end;

function GetJREBin(S: String): String;
begin
	Result :=JREBinPath;
end;

function GetOpenCVBit: String;
begin
	if (IsBoth64) then
	begin
		Result :='x64';
	end
	else
	begin
		Result :='x32';
	end;
end;

procedure setupEnvOpenCV();
var homedir: String;
begin
   homedir := ExpandConstant('{app}');
   if (IsBoth64()) then
    begin
      opencvHomeEnvVar :=homedir+'\build\x64\vc11';
    end
    else
    begin
      opencvHomeEnvVar :=homedir+'\build\x86\vc11' ;
    end
   RegWriteExpandStringValue(HKLM, '{#SystemEnvRegKey}', 'OPENCV_DIR', opencvHomeEnvVar);
   RegWriteExpandStringValue(HKLM, '{#SystemEnvRegKey}', 'BOWLER_HOME', homedir);
end;

