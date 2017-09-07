@echo off

call %~dp0\set_path_variables

SETLOCAL ENABLEDELAYEDEXPANSION
echo BUILDLOG %DATE%_%TIME% >build.log
echo ====================== >>build.log

if not exist temp mkdir temp

if not exist docs mkdir docs

FOR %%x IN (*.xml) DO (
  set filename=%%x
  set modelname=!filename:~0,-4!

  echo           **** generating hierarchical physical model:
  echo                                      ERmodel2.physical.xslt -hs
  echo                           !modelname!.xml ----------------^> temp\!modelname!.hierarchical.xml
  call %ERHOME%\scripts\generate_physicalandlog %%x
  echo. 

  echo.
  echo.
)
