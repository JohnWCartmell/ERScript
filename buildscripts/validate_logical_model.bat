@ECHO OFF

rem call %~dp0\set_path_variables

java -jar %JING_PATH%\jing.jar -f %SCHEMAS%\ERmodel.rng %SRCXML%\ERmodelERmodel.core.xml

java -jar %SAXON_JAR% -s:%SRCXML%\ERmodelERmodel.core.xml -xsl:%XSLT%/ERmodelERmodel.referential_integrity.xslt -o:%TEMP%\xml\ERmodelERmodel.validation.out.xml

