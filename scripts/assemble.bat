@echo off

REM run this from the folder which has the src xml file

if not exist ..\proto mkdir ..\proto

set filename=%1
set filenamebase=%filename:~0,-4%

call ..\..\ERmodel_v1.5\scripts\set_path_variables

java -jar %SAXON_PATH%\saxon9he.jar -s:%filenamebase%.xml -xsl:ERmodelAssemble.xslt -o:output.xml
