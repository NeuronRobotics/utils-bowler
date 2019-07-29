Dim objFSO
Dim objFile
Dim objFolder
Dim exePath 
Dim exeFullPath
Set objFSO = CreateObject("Scripting.FileSystemObject")
Set objFile = objFSO.GetFile(WScript.ScriptFullName)
Set objFolder = objFile.ParentFolder 
dim shell
Set shell=createobject("wscript.shell")
shell.CurrentDirectory =objFolder 
shell.run "BowlerStudio.bat" , 0 
set shell=nothing

