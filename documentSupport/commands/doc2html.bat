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

SET DOCHOME=%ERHOME%\documentSupport
echo dochome is %DOCHOME%

echo "Copy the css files"
if not exist %outputfolder%\css mkdir %outputfolder%\css
copy %DOCHOME%\css\erstyle.css %outputfolder%\css\erstyle.css
copy %DOCHOME%\css\cssmenustyles.css %outputfolder%\css\cssmenustyles.css
copy %DOCHOME%\css\print.css %outputfolder%\css\print.css
copy %DOCHOME%\css\printmenustyles.css %outputfolder%\css\printmenustyles.css

copy %ERHOME%\css\erdiagramsvgstyles.css %outputfolder%\css\erdiagramsvgstyles.css
copy %ERHOME%\css\ersvgdiagramwrapper.css %outputfolder%\css\ersvgdiagramwrapper.css
copy %ERHOME%\css\flexdiagrammingsvg.css %outputfolder%\css\flexdiagrammingsvg.css

java -jar %SAXON_JAR% -s:"%filepath%%filenamebase%.xml" -xsl:%DOCHOME%\xslt\document2.html.xslt -o:%filenamebase%.html rootfolder=%outputfolder%

