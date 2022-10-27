@ECHO OFF
REM Run this from the src folder

if not exist ..\logs mkdir ..\logs

set filename=%1
set filenamebase=%filename:~0,-4%

call %~dp0\set_path_variables

echo ********************************************** >>build.log
echo ** generate tex for %filename%                 >>build.log           
echo ********************************************** >>build.log

call %ERHOME%\scripts\genTex >..\logs\%filenamebase%.tex.log %1 2>&1  & type ..\logs\%filenamebase%.tex.log | findstr "[Ee]rror"

type ..\logs\%filenamebase%.tex.log >>..\build.log