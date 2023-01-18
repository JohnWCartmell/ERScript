
SETLOCAL ENABLEDELAYEDEXPANSION
echo BUILDLOG %DATE%_%TIME% >build.log
echo ====================== >>build.log
FOR %%x IN (*.xml) DO (
  set filename=%%x
  set modelname=!filename:~0,-4!
  echo           ***************************************
  echo                  !modelname!
  echo           ***************************************
  echo           **** checking schema of %%x
  call %~dp0\schema_check %%x
  echo.
  echo           **** elaborating: 
  echo                                      diagram.elaboration.xslt
  echo                           %%x ------------^> temp\!modelname!.elaborated.xml
  call %~dp0\elaborate %%x
  echo.
  echo           **** enriching:
  echo                                      diagram2.initial_enrichment.xslt
  echo                           !modelname!.elaborated.xml ------------^> temp\!modelname!.enriched.xml
  call %~dp0\enrich %%x
  echo. 
  echo           **** generating svg:
  echo                                      diagram2.svg.xslt
  echo                           !modelname!.enriched.xml ------------^> temp\!modelname!.svg
  call %~dp0\generate_svg %%x
  echo. 

  echo.
  echo.
)
