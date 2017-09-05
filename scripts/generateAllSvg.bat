
call %~dp0\set_path_variables

SETLOCAL ENABLEDELAYEDEXPANSION
echo BUILDLOG %DATE%_%TIME% >build.log
echo ====================== >>build.log
FOR %%x IN (*.xml) DO (
  set filename=%%x
  set modelname=!filename:~0,-4!

  echo           **** generating svg:
  echo                                      diagram2.svg.xslt
  echo                           !modelname!.enriched.xml ------------^> temp\!modelname!.svg
  call %ERHOME%\scripts\generate_svgandlog %%x
  echo. 

  echo.
  echo.
)
