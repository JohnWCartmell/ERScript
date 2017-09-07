@ECHO OFF

set filename=%1
set filenamebase=%filename:~0,-4%

call %~dp0\set_path_variables

echo ********************************************** >>build.log
echo ** generate hierarchical for %filename%                 >>build.log           
echo ********************************************** >>build.log

call %ERHOME%\scripts\genHierarchical >temp\%filenamebase%.hierarchical.log %1 2>&1  & type temp\%filenamebase%.hierarchical.log | findstr "[Ee]rror"

type temp\%filenamebase%.hierarchical.log >>build.log


echo ********************************************** >>build.log
echo ** generate relational for %filename%                 >>build.log           
echo ********************************************** >>build.log

call %ERHOME%\scripts\genRelational >temp\%filenamebase%.relational.log %1 2>&1  & type temp\%filenamebase%.relational.log | findstr "[Ee]rror"

type temp\%filenamebase%.relational.log >>build.log