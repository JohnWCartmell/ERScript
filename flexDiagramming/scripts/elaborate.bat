@ECHO OFF
set filename=%1
set filenamebase=%filename:~0,-4%

call %~dp0\set_path_variables.bat


java -jar %SAXON_JAR% -s:%filenamebase%.xml -xsl:%ERHOME%/xslt/diagram.elaboration.xslt -o:temp/%filenamebase%.elaborated.xml 




