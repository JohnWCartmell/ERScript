REM This script is designed to be used to build the examples distributed in folder "exampleDataModels".
REM The examples are built  from the windows command prompt. First cd to folder "exampleDataModels". Then run this script.

call %~dp0\set_path_variables
echo BUILDLOG %DATE%_%TIME%  >build.log


echo GENERATING ALL SVGs     >>build.log
cd src
call %ERHOME%\scripts\genAllSvg
cd ..


echo GENERATING ALL PHYSICAL >>build.log
cd src
call %ERHOME%\scripts\genAllPhysical
cd ..


echo GENERATING TEX for all logical >>build.log
cd src
call %ERHOME%\scripts\genAllTex
cd ..

echo GENERATING TEX for all  physical >>build.log
cd temp
call %ERHOME%\scripts\genAllTex
cd ..

echo GENERATING tex data model catalogue
powershell -f %ERHOME%\scripts\generate_tex_data_model_catalogue.ps1

echo Calling latex to build pdf
call %ERHOME%\scripts\genPDF
