@echo off

REM run this from the folder which has the src xml file

if not exist ..\temp mkdir ..\temp

set filename=%1
set filenamebase=%filename:~0,-4%

call %~dp0\scripts\set_path_variables

java -jar %SAXON_JAR% -s:%filenamebase%.xml -xsl:%ERHOME%\xslt\ERmodel.consolidate.xslt -o:..\temp\%filenamebase%.consolidated.xml
