SETLOCAL
@echo off

if "%2" == "" goto args_count_wrong
if "%3" == "" goto args_count_ok

:args_count_wrong
echo Useage:
echo    build ^<distribution^> ^<ER home^>
echo .
echo         for ^<distribution^> specify a path to an existing folder which is
echo         the folder which (when zipped) will be the software distribution. 
echo         This folder must already contain third party software (jars from Saxon and jing)
echo         for these are used in the build process.
echo .
echo         for ^<ER home^> specify the name of the ERmodel folder that is to be 
echo         created within the distribution.
exit /b 1

:args_count_ok

SET DISTRIBUTION=%1
SET ERHOMEFOLDERNAMEDURINGBUILD=%2

call %~dp0\set_build_path_variables

if not exist %SAXON_PATH% (
   echo For the build need third party software %SAXON_PATH%.
   goto :error
)

if not exist %JING_PATH% (
   echo For the build need third party software %JING_PATH%.
   goto :error
)
goto :continue

:error
exit /b 1

:continue

for %%* in (%DISTRIBUTION%) do set DISTRIBUTIONNAME=%%~nx*
if not exist %ERHOMEDIR% mkdir %ERHOMEDIR%
if not exist %ERHOMEDIR%\xml mkdir %ERHOMEDIR%\xml
if not exist %ERHOMEDIR%\temp mkdir %ERHOMEDIR%\temp
if not exist %ERHOMEDIR%\xslt mkdir %ERHOMEDIR%\xslt
if not exist %ERHOMEDIR%\docs mkdir %ERHOMEDIR%\docs
if not exist %ERHOMEDIR%\schemas mkdir %ERHOMEDIR%\schemas
if not exist %ERHOMEDIR%\logs mkdir %ERHOMEDIR%\logs

echo ERHOMEDIR %ERHOMEDIR%

echo "Copy the readme"
copy %SRCDIR%\readme.md %DISTRIBUTION%\readme.md

echo "Copy html index"
copy %SRCDIR%\html\index.html %DISTRIBUTION%\index.html

echo "Copy the meta-model"
xcopy %SRCDIR%\xml\ %ERHOMEDIR%\xml\ /q

echo "Copying source xslt files"
xcopy %SRCDIR%\xslt %ERHOMEDIR%\xslt\ /q

echo "Copying source batch file scripts"
xcopy %SRCDIR%\scripts %ERHOMEDIR%\scripts\ /q

rem echo editing index.html
rem powershell -Command "(gc %ERHOMEDIR%\scripts\set_path_variables.bat -Raw)  -replace 'ERHOMEFOLDERNAMEPLACEHOLDER', '%ERHOMEFOLDERNAMEDURINGBUILD%' | Out-File %ERHOMEDIR%\scripts\set_path_variables.bat"
rem couldnt get the above to work - as if it corrupted the .bat file in a way that I coudn't see

echo "Copying source commands"
xcopy %SRCDIR%\commands %DISTRIBUTION%\commands\ /q

echo "Copying latex"
xcopy %SRCDIR%\latex %ERHOMEDIR%\latex\ /q

echo "Copying source docs files"
xcopy %SRCDIR%\docs %ERHOMEDIR%\docs\ /q

echo "copying css files"
xcopy %SRCDIR%\css %DISTRIBUTION%\css\ /q

echo "copying js files"
xcopy %SRCDIR%\js %DISTRIBUTION%\js\ /q

if not exist %LOGS% mkdir %LOGS%

echo Logging to %LOGS%\build.log

echo BUILDLOG %DATE%_%TIME% >%LOGS%\build.log
echo ====================== >>%LOGS%\build.log


echo "building the meta model "
cd %ERHOMEDIR%\xml 
call ..\scripts\buildMetaModel.bat
REM WARNING THIS ABOVE call has the side effect of (re)setting DISTRIBUTION to be a  FULL PATH

echo validating the meta model is as instance of itself and has referential integrity
call ..\scripts\validate_logical_metamodel

echo validating the phsyical meta model  has referential integrity
call ..\scripts\validate_physical_metamodel
cd ..\..

echo Copying examples into distribution

xcopy %SRCDIR%\examplesConceptual %DISTRIBUTION%\examplesConceptual\ /q /s
powershell -Command "(gc %DISTRIBUTION%\examplesConceptual\readme.txt) -replace '<DISTRIBUTION>', '%DISTRIBUTIONNAME%' -replace '<ERHOME>', '%ERHOMEFOLDERNAMEDURINGBUILD%' | Out-File %DISTRIBUTION%\examplesConceptual\readme.txt"

xcopy %SRCDIR%\exampleDataModels %DISTRIBUTION%\exampleDataModels\ /q /s
powershell -Command "(gc %DISTRIBUTION%\exampleDataModels\readme.txt) -replace '<DISTRIBUTION>', '%DISTRIBUTIONNAME%' -replace '<ERHOME>', '%ERHOMEFOLDERNAMEDURINGBUILD%' | Out-File %DISTRIBUTION%\exampleDataModels\readme.txt"

xcopy %SRCDIR%\examplesSelected %DISTRIBUTION%\examplesSelected\ /q /s
powershell -Command "(gc %DISTRIBUTION%\examplesSelected\readme.txt) -replace '<DISTRIBUTION>', '%DISTRIBUTIONNAME%' -replace '<ERHOME>', '%ERHOMEFOLDERNAMEDURINGBUILD%' | Out-File %DISTRIBUTION%\examplesSelected\readme.txt"

echo building selected examples
cd examplesSelected
echo calling ..\%ERHOMEFOLDERNAMEDURINGBUILD%\scripts\buildAllLogicalandPhysical.bat
call ..\%ERHOMEFOLDERNAMEDURINGBUILD%\scripts\buildAllLogicalandPhysical.bat

cd ..\..

echo editing index.html
powershell -Command "(gc %DISTRIBUTION%\index.html) -replace '<DISTRIBUTION>', '%DISTRIBUTIONNAME%' -replace '<ERHOME>', '%ERHOMEFOLDERNAMEDURINGBUILD%' | Out-File %DISTRIBUTION%\index.html"

ENDLOCAL

