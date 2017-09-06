@ECHO OFF

rem call %~dp0\set_path_variables

java -jar %JING_PATH%\jing.jar -f %SCHEMAS%\ERmodel.rng %SRCXML%\ERmodelERmodel.xml

java -jar %SAXON_PATH%\saxon9he.jar -s:%SRCXML%\ERmodelERmodel.xml -xsl:%XSLT%/ERmodelERmodel.referential_integrity.xslt -o:%TEMP%\xml\ERmodelERmodel.validation.out.xml

