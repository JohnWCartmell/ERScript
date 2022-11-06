@echo off

set filename=%1
set filenamebase=%filename:~0,-4%

call %~dp0\set_path_variables

java -jar %SAXON_JAR% -s:%filenamebase%.xml -xsl:%ERHOME%\xslt\ERmodel2.physical.xslt -o:..\temp\%filenamebase%.relational.xml style=r

java -jar %SAXON_JAR% -s:..\temp\%filenamebase%.relational.xml -xsl:%ERHOME%\xslt\ERmodel2.svg.xslt -o:..\docs\%filenamebase%.relational.svg filestem=%filenamebase%.relational



