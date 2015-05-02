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
Name: {group}\BowlerStudio; Filename: {app}\{#MyAppSlug}-{#MyAppVersion}\bin\BowlerStudio.jar 
Name: {group}\{#MyAppVerName}; Filename: {app}\{#MyAppSlug}-{#MyAppVersion}\
Name: {commondesktop}\BowlerStudio; Filename: {app}\{#MyAppSlug}-{#MyAppVersion}\bin\BowlerStudio.jar; WorkingDir: {app}\{#MyAppSlug}-{#MyAppVersion}\bin\; Comment: "Neuron Robotics BowlerStudio";IconFilename: {app}\{#MyAppSlug}-{#MyAppVersion}\bin\NeuronRobotics.ico;



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
var
 ErrorCode: Integer;
 JavaInstalled : Boolean;
 Result1 : Boolean;
 Versions: TArrayOfString;
 I: Integer;
begin
 if RegGetSubkeyNames(HKLM, 'SOFTWARE\JavaSoft\Java Runtime Environment', Versions) then
 begin
  for I := 0 to GetArrayLength(Versions)-1 do
   if JavaInstalled = true then
   begin
    //do nothing
   end else
   begin
    if ( Versions[I][2]='.' ) and ( ( StrToInt(Versions[I][1]) > 1 ) or ( ( StrToInt(Versions[I][1]) = 1 ) and ( StrToInt(Versions[I][3]) >= 6 ) ) ) then
    begin
     JavaInstalled := true;
    end else
    begin
     JavaInstalled := false;
    end;
   end;
 end else
 begin
  JavaInstalled := false;
 end;


 //JavaInstalled := RegKeyExists(HKLM,'SOFTWARE\JavaSoft\Java Runtime Environment\1.9');
 if JavaInstalled then
 begin
  Result := true;
 end else
    begin
  Result1 := MsgBox('This tool requires Java Runtime Environment version 1.8 or newer to run. Please download and install the JRE and run this setup again. Do you want to download it now?',
   mbConfirmation, MB_YESNO) = idYes;
  if Result1 = false then
  begin
   Result:=false;
  end else
  begin
   Result:=false;
   ShellExec('open',
    'http://www.java.com/getjava/',
    '','',SW_SHOWNORMAL,ewNoWait,ErrorCode);
  end;
    end;
   end;
end.

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
#ifdef UNICODE
  #define AW "W"
#else
  #define AW "A"
#endif

#define SystemEnvRegKey "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"
#define CurUserEnvRegKey "Environment"

const
  SMTO_ABORTIFHUNG = 2;
  WM_WININICHANGE = $001A;
  WM_SETTINGCHANGE = WM_WININICHANGE;

type
  WPARAM = UINT_PTR;
  LPARAM = INT_PTR;
  LRESULT = INT_PTR;

function SetEnvironmentVariable(lpName: string; lpValue: string): BOOL;
  external 'SetEnvironmentVariable{#AW}@kernel32.dll stdcall';
function SendTextMessageTimeout(hWnd: HWND; Msg: UINT; wParam: WPARAM;
  lParam: string; fuFlags: UINT; uTimeout: UINT; out lpdwResult: DWORD): LRESULT;
  external 'SendMessageTimeout{#AW}@user32.dll stdcall';

procedure RefreshEnvironment;
var
  MsgResult: DWORD;
begin
  SendTextMessageTimeout(HWND_BROADCAST, WM_SETTINGCHANGE, 0, 'Environment',
    SMTO_ABORTIFHUNG, 5000, MsgResult);
end;

// function which sets environment variables for the setup process; processes
// executed from the setup after this function call will see the changes made
// because every process created by the setup inherits its environment block;
// changes made by this function are valid just for the setup process and are
// not persistent nor system wide
function SetEnvSetup(const Name, Value: string): Boolean;
begin
  Result := SetEnvironmentVariable(Name, Value);
end;

// function which persistently changes the system wide environment variables;
// changes made by this function call won't be seen by the setup process, nor
// the applications executed from it since Inno Setup does not modify its own
// environment block even if you send an environment change notification; the
// Refresh parameter in this function determines whether the running programs
// should be notified about the environment changes; when you set it to True,
// all running programs will be notified about this change and may reload the
// current settings; if you set it to False, no running program will notice a
// change (it's the immediate equivalent to the ChangesEnvironment directive)
function SetEnvSystem(const Name, Value: string; Refresh: Boolean): Boolean;
begin
  Result := RegWriteExpandStringValue(HKLM, '{#SystemEnvRegKey}', Name, Value);
  if Result and Refresh then
    RefreshEnvironment;
end;

// function that persistently changes the current user environment variables;
// changes made by this function call won't be seen by the setup process, nor
// the applications executed from it since Inno Setup does not modify its own
// environment block even if you send an environment change notification; the
// Refresh parameter in this function determines whether the running programs
// should be notified about the environment changes; when you set it to True,
// all running programs will be notified about this change and may reload the
// current settings; if you set it to False, no running program will notice a
// change (it's the immediate equivalent to the ChangesEnvironment directive)
function SetEnvCurUser(const Name, Value: string; Refresh: Boolean): Boolean;
begin
  Result := RegWriteExpandStringValue(HKCU, '{#CurUserEnvRegKey}', Name, Value);
  if Result and Refresh then
    RefreshEnvironment;
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
   SetEnvSystem( 'OPENCV_DIR', opencvHomeEnvVar,True);
   SetEnvSystem( 'BOWLER_HOME', homedir,True);

   SetEnvCurUser( 'OPENCV_DIR', opencvHomeEnvVar,True);
   SetEnvCurUser( 'BOWLER_HOME', homedir,True);
end;


[Registry]
Root: HKLM; SubKey: "SYSTEM\CurrentControlSet\Control\Session Manager\Environment";ValueType:string; ValueName: "BOWLER_HOME"; ValueData: {app}\{#MyAppSlug}-{#MyAppVersion};  Flags: preservestringtype ;
Root: HKLM; SubKey: "SYSTEM\CurrentControlSet\Control\Session Manager\Environment";ValueType:string; ValueName: "OPENCV_DIR"; ValueData: {app}\{#MyAppSlug}-{#MyAppVersion}\build\x64\vc11;  Flags: preservestringtype ;
