@echo off

set filepath=%~dp1
set filename=%~nx1
set filenamebase=%filename:~0,-4%

set outputfolder=%2

call %~dp0\copy_and_elaborate_and_schema_check %1 %2

call %~dp0\doc2html temp\%filenamebase%.completed.xml %2
