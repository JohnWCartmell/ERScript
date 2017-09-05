@ECHO OFF

call %~dp0\set_path_variables

java -jar %SAXON_PATH%\saxon9he.jar -s:%XML%\ERmodelERmodel.physical.xml -xsl:%XSLT%/ERmodelERmodel.referential_integrity.xslt -o:%TEMP%\xml\ERmodelERmodel.physical.validation.out.xml 

