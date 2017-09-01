@ECHO OFF

call %~dp0\set_path_variables

java -jar %SAXON_PATH%\saxon9he.jar -s:%TEMP%\xml\ERmodelERmodel.physical.xml -xsl:%SCHEMAS%/ERmodelERmodel.referential_integrity.xslt -o:%TEMP%\xml\ERmodelERmodel.physical.validation.out.xml 

