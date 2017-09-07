@ECHO OFF

set filename=%1
set filenamebase=%filename:~0,-4%

call %~dp0\set_path_variables

echo ********************************************** >>build.log
echo ** generate physical for %filename%                 >>build.log           
echo ********************************************** >>build.log

call %ERHOME%\scripts\generate_physical >temp\%filenamebase%.physical.log %1 2>&1  & type temp\%filenamebase%.physical.log | findstr "[Ee]rror"

type temp\%filenamebase%.physical.log >>build.log