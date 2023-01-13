@ECHO OFF
REM run this from the folder which has the src xml file for the model 

if not exist ..\temp mkdir ..\temp

set filename=%1
set filenamebase=%filename:~0,-4%

call %~dp0\set_path_variables

java -jar %JING_PATH%\jing.jar -f %ERHOME%\schemas\ERmodel.rng %filenamebase%.xml

java -jar %SAXON_JAR% -s:%filenamebase%.xml -xsl:%ERHOME%\xslt\ERmodelERmodel.referential_integrity.xslt -o:..\temp\ERmodelERmodel.validation.out.xml

