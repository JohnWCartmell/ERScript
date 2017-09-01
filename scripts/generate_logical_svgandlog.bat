
call %~dp0\set_path_variables

call %~dp0\generate_logical_svg >%LOGS%\ERmodelERmodel.logical.svg.log 2>&1  & type %LOGS%\ERmodelERmodel.logical.svg.log | findstr "[Ee]rror"
echo ********************************************** >>%LOGS%\build.log
echo ** generate svg from ERmodelERmodel.xml        >>%LOGS%\build.log           
echo ********************************************** >>%LOGS%\build.log
type %LOGS%\ERmodelERmodel.logical.svg.log >>%LOGS%\build.log

