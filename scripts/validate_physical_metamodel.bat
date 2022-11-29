@echo off
REM run this from the xml folder which has the meta model src files:
REM See  readme.md for an explanation of the source files.

if not exist ..\temp mkdir ..\temp

call %~dp0\set_path_variables

REM PART ONE 
REM physical (without  diagram being in the model or in the data)

REM jing will fail until physical enrichment specified in meta model
java -jar %JING_PATH%\jing.jar -f %ERHOME%\schemas\ERA.rng ERA..physical.xml

java -jar %SAXON_JAR% -s:ERA..physical.xml -xsl:%ERHOME%\xslt\ERmodelERmodel.referential_integrity.xslt -o:..\temp\ERmodelERmodel.physical.validation.out.xml

REM PART TWO
REM physical including model of diagram and including instance of diagram

java -jar %SAXON_JAR% -s:ERAdiagrammed..physical..diagram.xml -xsl:%ERHOME%\xslt\ERmodel.consolidate.xslt -o:..\temp\ERAdiagrammed..physical..diagram.consolidated.xml

java -jar %JING_PATH%\jing.jar -f %ERHOME%\schemas\ERAdiagrammed.rng ..\temp\ERAdiagrammed..physical..diagram.consolidated.xml

java -jar %SAXON_JAR% -s:..\temp\ERAdiagrammed..physical..diagram.consolidated.xml -xsl:%ERHOME%\xslt\ERmodelERmodel.referential_integrity.xslt -o:..\temp\ERAdiagrammed..physical..diagram.consolidated.validation.out.xml

