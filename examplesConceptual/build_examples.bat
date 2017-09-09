cd src
call ..\..\ERmodel_v1.3\scripts\genAllSvg
cd ..

cd src
call ..\..\ERmodel_v1.3\scripts\genAllTex
cd ..

powershell ..\ERmodel_v1.3\scripts\generate_tex_concepts_catalogue.ps1

call ..\ERmodel_v1.3\scripts\genPDF
