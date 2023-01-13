@echo off
REM Run this scrip from the examples folder

call %~dp0\set_path_variables

SETLOCAL ENABLEDELAYEDEXPANSION
echo BUILDLOG %DATE%_%TIME% >build.log
echo ====================== >>build.log

cd src
FOR %%x IN (*.xml) DO (
  set filename=%%x
  set modelname=!filename:~0,-4!

  echo           **** generating logical tex:
  echo                                      ERmodel2.tex.xslt
  echo                           !modelname!.xml ------------^> latex\!modelname!.tex
  call %ERHOME%\scripts\generate_texandlog %%x
  echo. 
)
cd ..\temp
FOR %%x IN (*.xml) DO (
  set filename=%%x
  set modelname=!filename:~0,-4!

  echo           **** generating physical tex:
  echo                                      ERmodel2.tex.xslt
  echo                           !modelname!.xml ------------^> latex\!modelname!.tex
  call %ERHOME%\scripts\generate_texandlog %%x
  echo. 
)
cd ..


