@ECHO OFF
set filename=%1
set filenamebase=%filename:~0,-4%
call %~dp0\elaborate >temp\%filenamebase%.elaborate.log %1 2>&1  & type temp\%filenamebase%.elaborate.log | findstr "[Ee]rror"
echo ********************************************** >>build.log
echo ** elaborate %filename%                           >>build.log           
echo ********************************************** >>build.log
type temp\%filenamebase%.elaborate.log >>build.log

