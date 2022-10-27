@ECHO OFF
REM Run this from the src folder

if not exist ..\logs mkdir ..\logs

set filename=%1
set filenamebase=%filename:~0,-4%

call %~dp0\set_path_variables

echo ********************************************** >>build.log
echo ** generate svg for %filename%                 >>build.log           
echo ********************************************** >>build.log

call %ERHOME%\scripts\genSvg >..\logs\%filenamebase%.svg.log %1 2>&1  & type ..\logs\%filenamebase%.svg.log | findstr "[Ee]rror"

type ..\logs\%filenamebase%.svg.log >>..\build.log