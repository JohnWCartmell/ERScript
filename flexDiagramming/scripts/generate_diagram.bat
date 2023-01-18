
set filename=%1
set filenamebase=%filename:~0,-4%

call %~dp0\set_path_variables.bat

SET FLEXXSLT=%ERHOME%\flexDiagramming\xslt

java -jar %SAXON_JAR% -s:%filenamebase%.xml -xsl:%FLEXXSLT%/ERmodel2.diagram.xslt -o:%filenamebase%.diagram.xml 
