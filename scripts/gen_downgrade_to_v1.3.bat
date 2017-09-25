@echo off
call %~dp0\set_path_variables

set filename=%1
set filenamebase=%filename:~0,-4%

call %~dp0\set_path_variables

java -jar %SAXON_PATH%\saxon9he.jar -s:%filenamebase%.xml -xsl:%ERHOME%\xslt\ERmodel_v1.4_to_ERmodel_v1.3.xslt -o:..\temp\%filenamebase%.xml 



