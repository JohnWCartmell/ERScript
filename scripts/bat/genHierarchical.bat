@echo off

set filename=%1
set filenamebase=%filename:~0,-4%

call %~dp0\set_path_variables

java -jar %SAXON_JAR% -s:%filenamebase%.xml -xsl:%ERHOME%\xslt\ERmodel2.physical.xslt -o:..\temp\%filenamebase%.hierarchical.xml style=h debug=y

REM Remove call to genSVG since often will need additional presentation input for a diagram
REM java -jar %SAXON_JAR% -s:..\temp\%filenamebase%.hierarchical.xml -xsl:%ERHOME%\xslt\ERmodel2.svg.xslt -o:..\docs\%filenamebase%.hierarchical.svg filestem=%filenamebase%.hierarchical 



