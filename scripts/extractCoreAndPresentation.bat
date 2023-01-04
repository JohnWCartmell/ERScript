@echo off

REM run this from the folder which has the src xml file
REM this script meets a temporary requirement to separate out presentation information from an entity model
REM (in future presentation and semantic information will be held in separate source files and put together
REM using new "assembly" functionality).

if not exist ..\temp mkdir ..\temp

set filename=%1
set filenamebase=%filename:~0,-4%

call %~dp0\set_path_variables

java -jar %SAXON_JAR% -s:%filenamebase%.xml -xsl:%ERHOME%\xslt\ERmodel2.presentation.xslt -o:..\temp\%filenamebase%..presentation.xml

java -jar %SAXON_JAR% -s:%filenamebase%.xml -xsl:%ERHOME%\xslt\ERmodel2.core.xslt -o:..\temp\%filenamebase%..logical.xml

java -jar %SAXON_JAR% -s:%filenamebase%.xml -xsl:%ERHOME%\xslt\ERmodel2.main.xslt -o:..\temp\%filenamebase%..diagram.xml filestem=%filenamebase%
