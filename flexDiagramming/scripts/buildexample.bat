@ECHO OFF
set filename=%1
set filenamebase=%filename:~0,-4%

echo           **** checking schema 
call %~dp0\schema_check %1
echo.
echo           **** elaborating: 
call %~dp0\elaborate %1
echo.
echo           **** enriching:
call %~dp0\enrich %1
echo. 
echo           **** generating svg:
call %~dp0\generate_svg %1