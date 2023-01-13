REM This script is designed to be used to build the examples distributed in folder "examplesConceptual".
REM The examples are built  from the windows command prompt. First cd to folder "exampleConceptual". Then run this script.

call %~dp0\set_path_variables

echo BUILDLOG %DATE%_%TIME%  >build.log

cd src
call %ERHOME%\scripts\genAllSvg
call %ERHOME%\scripts\genAllTex
cd ..

powershell %ERHOME%\scripts\generate_tex_concepts_catalogue.ps1

call %ERHOME%\scripts\genPDF
