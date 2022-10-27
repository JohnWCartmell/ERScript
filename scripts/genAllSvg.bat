@echo off
REM Run this from the src folder

call %~dp0\set_path_variables

SETLOCAL ENABLEDELAYEDEXPANSION
echo BUILDLOG %DATE%_%TIME% >..\build.log
echo ====================== >>..\build.log

if not exist ..\docs mkdir ..\docs
copy %ERHOME%\docs\erstyle.css ..\docs\erstyle.css

FOR %%x IN (*.xml) DO (
  set filename=%%x
  set modelname=!filename:~0,-4!

  echo           **** generating svg:
  echo                                      ERmodel2.svg.xslt
  echo                           !modelname!.xml ------------^> docs\!modelname!.svg
  call %ERHOME%\scripts\generate_svgandlog %%x
  echo. 

  echo.
  echo.
)
