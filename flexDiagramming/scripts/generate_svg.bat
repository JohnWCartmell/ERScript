
set filename=%1
set filenamebase=%filename:~0,-4%

call %~dp0\set_path_variables.bat

SET FLEXXSLT=%ERHOME%\flexDiagramming\xslt

java -jar %SAXON_JAR% -s:temp/%filenamebase%.enriched.xml -xsl:%FLEXXSLT%\diagram2.svg.xslt -o:docs/%filenamebase%.svg filestem=%filenamebase% animate=y
