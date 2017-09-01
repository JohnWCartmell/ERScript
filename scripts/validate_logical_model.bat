@ECHO OFF

call %~dp0\set_path_variables

java -jar %JING_PATH%\jing.jar -f %SCHEMAS%\ERmodel.rng %SRC%\ERmodelERmodel.xml

java -jar %SAXON_PATH%\saxon9he.jar -s:ERmodelERmodel.xml -xsl:%SCHEMAS%/ERmodelERmodel.referential_integrity.xslt -o:%TEMP%\xml\ERmodelERmodel.validation.out.xml

