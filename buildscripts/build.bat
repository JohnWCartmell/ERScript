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
SET ERHOME=%2

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

echo "Copy the readme"
copy %SRCDIR%\readme.md %DISTRIBUTION%\readme.md

echo "Copy the meta-model"
copy %SRCDIR%\xml\ERmodelERmodel.core.xml %ERHOMEDIR%\xml\ERmodelERmodel.core.xml
copy %SRCDIR%\xml\ERmodelERmodel.core.presentation.xml %ERHOMEDIR%\xml\ERmodelERmodel.core.presentation.xml
copy %SRCDIR%\xml\ERmodelERmodel.core.diagram.xml %ERHOMEDIR%\xml\ERmodelERmodel.core.diagram.xml
copy %SRCDIR%\xml\ERmodelERmodel.physical.diagram.xml %ERHOMEDIR%\xml\ERmodelERmodel.physical.diagram.xml

echo "Copying source xslt files"
xcopy %SRCDIR%\xslt %ERHOMEDIR%\xslt\ /q

echo "Copying source batch file scripts"
xcopy %SRCDIR%\scripts %ERHOMEDIR%\scripts\ /q

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


echo Generating ERmodel.svg
call %~dp0\generate_logical_svgandlog

echo Generating physical data model and the XML schema (ERmodel.rng)
call %~dp0\generate_physical_modelandlog

echo validating the meta model is as instance of itself and has referential integrity
call %~dp0\validate_logical_model

echo validating the phsyical meta model  has referential integrity
call %~dp0\validate_physical_model

echo Copying examples into distribution

xcopy %SRCDIR%\examplesConceptual %DISTRIBUTION%\examplesConceptual\ /q /s
powershell -Command "(gc %DISTRIBUTION%\examplesConceptual\readme.txt) -replace '<DISTRIBUTION>', '%DISTRIBUTIONNAME%' -replace '<ERHOME>', '%ERHOME%' | Out-File %DISTRIBUTION%\examplesConceptual\readme.txt"

xcopy %SRCDIR%\exampleDataModels %DISTRIBUTION%\exampleDataModels\ /q /s
powershell -Command "(gc %DISTRIBUTION%\exampleDataModels\readme.txt) -replace '<DISTRIBUTION>', '%DISTRIBUTIONNAME%' -replace '<ERHOME>', '%ERHOME%' | Out-File %DISTRIBUTION%\exampleDataModels\readme.txt"

ENDLOCAL



  
