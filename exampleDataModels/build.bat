cd src

call ..\..\ERmodel_v1.3\scripts\genAllSvg

call ..\..\ERmodel_v1.3\scripts\genAllPhysical

cd ..

cd src

call ..\..\ERmodel_v1.3\scripts\genAllTex

cd ..

cd temp

call ..\..\ERmodel_v1.3\scripts\genAllTex

cd ..

powershell ..\ERmodel_v1.3\scripts\generate_tex_data_model_catalogue.ps1

call ..\ERmodel_v1.3\scripts\genPDF
