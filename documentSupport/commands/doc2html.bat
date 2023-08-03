@echo off

SETLOCAL
@echo off

if "%2" == "" goto args_count_wrong
if "%3" == "" goto args_count_ok


:args_count_wrong
echo Useage:
echo    doc2html ^<document^> ^<outputfolder^>
echo .
echo         for ^<document^> specify a path to an xml file described by
echo         the documentModel schema.
echo .
echo         for ^<output folder^> specify the name of an existing folder 
echo         in which the website is to be created.
exit /b 1

:args_count_ok


set filepath=%~dp1
set filename=%~nx1
set filenamebase=%filename:~0,-4%

set outputfolder=%2

call %~dp0\set_path_variables

if not exist %ERHOMEDIR%\schemas mkdir %ERHOMEDIR%\schemas
echo dochome is %DOCHOME%

echo "Copy the css files"
copy %DOCHOME%\docs\erstyle.css %outputfolder%\erstyle.css
copy %DOCHOME%\docs\cssmenustyles.css %outputfolder%\cssmenustyles.css
copy %DOCHOME%\docs\print.css %outputfolder%\print.css
copy %DOCHOME%\docs\printmenustyles.css %outputfolder%\printmenustyles.css


java -jar %SAXON_JAR% -s:"%filepath%%filenamebase%.xml" -xsl:%DOCHOME%\xslt\document2.html.xslt -o:%filenamebase%.html rootfolder=%outputfolder%

