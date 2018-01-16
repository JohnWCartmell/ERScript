@ECHO OFF

call %~dp0\set_path_variables

set filename=%1
set filenamebase=%filename:~0,-4%

call %~dp0\set_path_variables

echo ********************************************** >>build.log
echo ** generate tex for %filename%                 >>build.log           
echo ********************************************** >>build.log

call %ERHOME%\scripts\genTex >temp\%filenamebase%.tex.log %1 2>&1  & type temp\%filenamebase%.tex.log | findstr "[Ee]rror"

type temp\%filenamebase%.tex.log >>build.log