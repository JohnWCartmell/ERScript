@ECHO OFF
set filename=%1
set filenamebase=%filename:~0,-4%

call %~dp0\enrich >temp\%filenamebase%.enrich.log %1 2>&1  & type temp\%filenamebase%.enrich.log | findstr "[Ee]rror"
echo ********************************************** >>build.log
echo ** enrich %filename%                           >>build.log           
echo ********************************************** >>build.log
type temp\%filenamebase%.enrich.log >>build.log

