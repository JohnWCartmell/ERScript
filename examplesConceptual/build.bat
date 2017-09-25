

echo BUILDLOG %DATE%_%TIME%  >build.log

echo Downgrading to v1.3
cd src
call ..\..\ERmodel_v1.4\scripts\downgrade_all_to_v1.3
cd ..

cd src
call ..\..\ERmodel_v1.4\scripts\genAllSvg
cd ..

cd temp
call ..\..\ERmodel_v1.4\scripts\genAllTex
cd ..

powershell ..\ERmodel_v1.4\scripts\generate_tex_concepts_catalogue.ps1

call ..\ERmodel_v1.4\scripts\genPDF
