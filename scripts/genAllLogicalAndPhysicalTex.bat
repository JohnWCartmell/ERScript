@echo off

call %~dp0\set_path_variables

SETLOCAL ENABLEDELAYEDEXPANSION
echo BUILDLOG %DATE%_%TIME% >build.log
echo ====================== >>build.log

if not exist temp mkdir temp


FOR %%x IN (*.xml) DO (
  set filename=%%x
  set modelname=!filename:~0,-4!

  echo           **** generating logical tex:
  echo                                      ERmodel2.tex.xslt
  echo                           !modelname!.xml ------------^> latex\!modelname!.tex
  call %ERHOME%\scripts\generate_texandlog %%x
  echo. 
  
  echo           **** generating hierarchical tex:
  echo                                      ERmodel2.tex.xslt
  echo                           !modelname!.hierarchical.xml ------------^> latex\!modelname!.hierarchical.tex
  call %ERHOME%\scripts\generate_texandlog ..\temp\!modelname!.hierarchical.xml
  echo. 
   
  echo           **** generating relational tex:
  echo                                      ERmodel2.tex.xslt
  echo                           !modelname!.relational.xml ------------^> latex\!modelname!.relational.tex
  call %ERHOME%\scripts\generate_texandlog ..\temp\!modelname!.relational.xml
  echo. 

  echo.
  echo.
)
