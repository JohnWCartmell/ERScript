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

  echo         **** generating hierarchical  model:
  echo.
  echo                              ERmodel2.physical.xslt style=h
  echo             !modelname!.xml --------------------^> temp\!modelname!.hierarchical.xml
  echo .
  echo                             then svg for hierarchical physical model:
  echo .
  echo                              ERmodel2.svg.xslt 
  echo                             --------------------^> docs\!modelname!.hierarchical.svg
  echo .
  echo         **** generating relational  model:
  echo .
  echo                              ERmodel2.physical.xslt style=r
  echo             !modelname!.xml --------------------^> temp\!modelname!.relational.xml
  echo .
  echo                             then svg for relational model:
  echo .
  echo                              ERmodel2.svg.xslt 
  echo                             --------------------^> docs\!modelname!.relational.svg

  call %ERHOME%\scripts\generate_physicalandlog %%x
  echo. 

  echo.
  echo.
)
