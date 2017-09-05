
@echo off

call %~dp0\set_path_variables

if not exist %LOGS% mkdir %LOGS%

echo BUILDLOG %DATE%_%TIME% >%LOGS%\build.log
echo ====================== >>%LOGS%\build.log

call %~dp0\generate_logical_svgandlog

call %~dp0\generate_physical_modelandlog

call %~dp0\validate_logical_model

call %~dp0\validate_physical_model
  