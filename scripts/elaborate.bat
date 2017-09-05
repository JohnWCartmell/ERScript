@ECHO OFF
set filename=%1
set filenamebase=%filename:~0,-4%

call %~dp0\set_path_variables

java -jar %SAXON_PATH%\saxon9he.jar -s:%filenamebase%.xml -xsl:%DIAGRAM_SCHEMAS%/diagram.elaboration.xslt -o:temp/%filenamebase%.elaborated.xml 




