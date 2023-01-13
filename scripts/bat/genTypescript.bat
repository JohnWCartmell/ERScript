@echo off

REM run this from the folder which has the src xml file

if not exist ..\typescript mkdir ..\typescript

set filename=%1
set filenamebase=%filename:~0,-4%

call %~dp0\set_path_variables

java -jar %SAXON_JAR% -s:%filenamebase%.xml -xsl:%ERHOME%\xslt\ERmodel2.ts.xslt -o:..\typescript\%filenamebase%.ts
