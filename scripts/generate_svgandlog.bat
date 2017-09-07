@ECHO OFF

set filename=%1
set filenamebase=%filename:~0,-4%

call %~dp0\set_path_variables

echo ********************************************** >>build.log
echo ** generate svg for %filename%                 >>build.log           
echo ********************************************** >>build.log

call %ERHOME%\scripts\generate_svg >temp\%filenamebase%.svg.log %1 2>&1  & type temp\%filenamebase%.svg.log | findstr "[Ee]rror"

type temp\%filenamebase%.svg.log >>build.log