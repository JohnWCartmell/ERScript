
echo BUILDLOG %DATE%_%TIME%  >build.log

echo Downgrading to v1.3
cd src
call ..\..\ERmodel_v1.4\scripts\downgrade_all_to_v1.3
cd ..

echo GENERATING ALL SVGs     >>build.log
cd src
call ..\..\ERmodel_v1.4\scripts\genAllSvg
cd ..
type src\build.log           >>build.log


echo GENERATING ALL PHYSICAL >>build.log
cd src
call ..\..\ERmodel_v1.4\scripts\genAllPhysical
cd ..
type src\build.log           >>build.log

goto skip
echo GENERATING TEX for all logical >>build.log
cd src
call ..\..\ERmodel_v1.4\scripts\genAllTex
cd ..
type src\build.log           >>build.log

:skip
echo GENERATING TEX for all downgraded logical and physical >>build.log
cd temp
call ..\..\ERmodel_v1.4\scripts\genAllTex
cd ..
type temp\build.log           >>build.log


powershell ..\ERmodel_v1.4\scripts\generate_tex_data_model_catalogue.ps1
call ..\ERmodel_v1.4\scripts\genPDF
