@ECHO OFF
set filename=%1
set filenamebase=%filename:~0,-4%

echo           **** checking schema 
call %~dp0\schema_check %1
echo. 
echo           **** generating svg:
call %~dp0\generate_svg %1