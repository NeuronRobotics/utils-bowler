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









; Both DecodeVersion and CompareVersion functions where taken from the  wiki
procedure DecodeVersion (verstr: String; var verint: array of Integer);
var
  i,p: Integer; s: string;
begin
  // initialize array
  verint := [0,0,0,0];
  i := 0;
  while ((Length(verstr) > 0) and (i < 4)) do
  begin
    p := pos ('.', verstr);
    if p > 0 then
    begin
      if p = 1 then s:= '0' else s:= Copy (verstr, 1, p - 1);
      verint[i] := StrToInt(s);
      i := i + 1;
      verstr := Copy (verstr, p+1, Length(verstr));
    end
    else
    begin
      verint[i] := StrToInt (verstr);
      verstr := '';
    end;
  end;

end;

function CompareVersion (ver1, ver2: String) : Integer;
var
  verint1, verint2: array of Integer;
  i: integer;
begin

  SetArrayLength (verint1, 4);
  DecodeVersion (ver1, verint1);

  SetArrayLength (verint2, 4);
  DecodeVersion (ver2, verint2);

  Result := 0; i := 0;
  while ((Result = 0) and ( i < 4 )) do
  begin
    if verint1[i] > verint2[i] then
      Result := 1
    else
      if verint1[i] < verint2[i] then
        Result := -1
      else
        Result := 0;
    i := i + 1;
  end;

end;

function InitializeSetup(): Boolean;
var
  ErrorCode: Integer;
  JavaVer : String;
  Result1 : Boolean;
begin
  
	RegQueryStringValue(HKLM, 'SOFTWARE\JavaSoft\Java Runtime Environment', 'CurrentVersion', JavaVer);
    Result := false;
    if Length( JavaVer ) > 0 then
    begin
    	if CompareVersion(JavaVer,'1.9') >= 0 then
    	begin
    		Result := true;
    	end;
    end;
    if Result = false then
    begin
    	Result1 := MsgBox('This tool requires Java Runtime Environment v1.8_45 or older to run. Please download and install JRE and run this setup again.' + #13 + #10 + 'Do you want to download it now?',
    	  mbConfirmation, MB_YESNO) = idYes;
    	if Result1 = true then
    	begin
    		ShellExec('open',
    		  'http://www.java.com/en/download/manual.jsp#win',
    		  '','',SW_SHOWNORMAL,ewNoWait,ErrorCode);
    	end;
    end;
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



[Registry]
Root: HKLM; SubKey: "SYSTEM\CurrentControlSet\Control\Session Manager\Environment";ValueType:string; ValueName: "BOWLER_HOME"; ValueData: {app}\{#MyAppSlug}-{#MyAppVersion};  Flags: preservestringtype ;
if IsWin64 then
	Root: HKLM; SubKey: "SYSTEM\CurrentControlSet\Control\Session Manager\Environment";ValueType:string; ValueName: "OPENCV_DIR"; ValueData: {app}\{#MyAppSlug}-{#MyAppVersion}\build\x64\vc11;  Flags: preservestringtype ;
else
	Root: HKLM; SubKey: "SYSTEM\CurrentControlSet\Control\Session Manager\Environment";ValueType:string; ValueName: "OPENCV_DIR"; ValueData: {app}\{#MyAppSlug}-{#MyAppVersion}\build\x86\vc11;  Flags: preservestringtype ;
