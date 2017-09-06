
rem call %~dp0\set_path_variables

call %~dp0\generate_physical_model >%LOGS%\ERmodelERmodel.logical2physical.log 2>&1  & type %LOGS%\ERmodelERmodel.logical2physical.log | findstr "[Ee]rror"
echo **************************************************        >>%LOGS%\build.log
echo ** generate physical model from ERmodelERmodel.xml        >>%LOGS%\build.log           
echo **************************************************        >>%LOGS%\build.log
type %LOGS%\ERmodelERmodel.logical2physical.log >>%LOGS%\build.log

