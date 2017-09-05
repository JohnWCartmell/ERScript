
set filename=%1
set filenamebase=%filename:~0,-4%

call %~dp0\set_path_variables

echo ERHOME %ERHOME%

java -jar %SAXON_PATH%\saxon9he.jar -s:%filenamebase%.xml -xsl:%ERHOME%\xslt\ERmodel2.svg.xslt -o:docs\%filenamebase%.svg filestem=%filenamebase%
