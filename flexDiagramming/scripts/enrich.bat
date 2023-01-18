echo off
set filename=%1
set filenamebase=%filename:~0,-4%

call %~dp0\set_path_variables.bat

SET FLEXXSLT=%ERHOME%\flexDiagramming\xslt

java -jar %SAXON_JAR% -s:temp/%filenamebase%.elaborated.xml -xsl:%FLEXXSLT%/diagram2.initial_enrichment.xslt -o:temp/%filenamebase%.enriched.xml filestem=%filenamebase%
