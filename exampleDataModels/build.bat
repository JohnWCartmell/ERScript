
echo BUILDLOG %DATE%_%TIME%  >build.log


echo GENERATING ALL SVGs     >>build.log
cd src
call ..\..\ERmodel_v1.3\scripts\genAllSvg
cd ..
type src\build.log           >>build.log


echo GENERATING ALL PHYSICAL >>build.log
cd src
call ..\..\ERmodel_v1.3\scripts\genAllPhysical
cd ..
type src\build.log           >>build.log


echo GENERATING TEX for all logical >>build.log
cd src
call ..\..\ERmodel_v1.3\scripts\genAllTex
cd ..
type src\build.log           >>build.log


echo GENERATING TEX for all physical >>build.log
cd temp
call ..\..\ERmodel_v1.3\scripts\genAllTex
cd ..
type temp\build.log           >>build.log


powershell ..\ERmodel_v1.3\scripts\generate_tex_data_model_catalogue.ps1
call ..\ERmodel_v1.3\scripts\genPDF
