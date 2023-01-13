@echo off
REM run this from the xml folder which has the meta model src files:
REM See  readme.md for an explanation of the source files.

if not exist ..\temp mkdir ..\temp

call %~dp0\set_path_variables

REM logical (without diagram model)

java -jar %SAXON_JAR% -s:ERA..logical.xml -xsl:%ERHOME%\xslt\ERmodel.consolidate.xslt -o:..\temp\ERA..logical.consolidated.xml

java -jar %JING_PATH%\jing.jar -f %ERHOME%\schemas\ERA.rng ..\temp\ERA..logical.consolidated.xml

java -jar %SAXON_JAR% -s:ERA..logical.xml -xsl:%ERHOME%\xslt\ERmodelERmodel.referential_integrity.xslt -o:..\temp\ERA..logical.validation.out.xml

REM logical with diagram model and with instance of diagram

java -jar %SAXON_JAR% -s:ERAdiagrammed..diagram.xml -xsl:%ERHOME%\xslt\ERmodel.consolidate.xslt -o:..\temp\ERAdiagrammed..diagram.consolidated.xml

java -jar %JING_PATH%\jing.jar -f %ERHOME%\schemas\ERAdiagrammed.rng ..\temp\ERAdiagrammed..diagram.consolidated.xml

java -jar %SAXON_JAR% -s:..\temp\ERAdiagrammed..diagram.consolidated.xml -xsl:%ERHOME%\xslt\ERmodelERmodel.referential_integrity.xslt -o:..\temp\ERAdiagrammed..diagram.consolidated.validation.out.xml

