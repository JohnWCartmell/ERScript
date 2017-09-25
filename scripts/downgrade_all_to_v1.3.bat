@echo off

call %~dp0\set_path_variables

SETLOCAL ENABLEDELAYEDEXPANSION
echo BUILDLOG %DATE%_%TIME% >build.log
echo ====================== >>build.log

if not exist temp mkdir temp

if not exist docs mkdir docs

FOR %%x IN (*.xml) DO (
  set filename=%%x
  set modelname=!filename:~0,-4!
  echo downgrade !filename! as intermediate v1.3
  call %ERHOME%\scripts\gen_downgrade_to_v1.3 %%x

)
