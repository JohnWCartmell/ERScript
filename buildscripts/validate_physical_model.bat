@ECHO OFF

rem call %~dp0\set_path_variables

java -jar %SAXON_JAR% -s:%XML%\ERmodelERmodel.physical.xml -xsl:%XSLT%/ERmodelERmodel.referential_integrity.xslt -o:%TEMP%\xml\ERmodelERmodel.physical.validation.out.xml 

