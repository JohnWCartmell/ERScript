@echo off

call %~dp0\set_path_variables

SETLOCAL ENABLEDELAYEDEXPANSION
echo BUILDLOG %DATE%_%TIME% >build.log
echo ====================== >>build.log

if not exist temp mkdir temp


FOR %%x IN (*.xml) DO (
  set filename=%%x
  set modelname=!filename:~0,-4!

  echo           **** generating tex:
  echo                                      ERmodel2.tex.xslt
  echo                           !modelname!.xml ------------^> latex\!modelname!.tex
  call %ERHOME%\scripts\generate_texandlog %%x
  echo. 

  echo.
  echo.
)
