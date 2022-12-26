@echo off
REM run this from the xml folder which has the meta model src files:
REM See  readme.md for an explanation of the source files.

if not exist ..\docs mkdir ..\docs

call %~dp0\set_path_variables

REM java -jar %SAXON_JAR% -s:%filenamebase%.xml -xsl:%ERHOME%\xslt\ERmodel2.svg.xslt -o:..\docs\%filenamebase%.svg filestem=%filenamebase% ERhomeFolderName=%ERHOMEFOLDERNAME%

REM LOGICAL DIAGRAMS AND REPORTING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

REM call %ERHOME%\scripts\genSVG ERA..diagram.xml
powershell -Command "%ERHOME%\scripts\genSVG.ps1  ERA..diagram.xml -animate"

java -jar %SAXON_JAR% -s:ERA..diagram.xml -xsl:%ERHOME%\xslt\ERmodel2.html.xslt -o:..\docs\ERA..report.html

REM call %ERHOME%\scripts\genSVG ERAdiagrammed..diagram.xml
powershell -Command "%ERHOME%\scripts\genSVG.ps1  ERAdiagrammed..diagram.xml -animate"

java -jar %SAXON_JAR% -s:ERAdiagrammed..diagram.xml -xsl:%ERHOME%\xslt\ERmodel2.html.xslt -o:..\docs\ERAdiagrammed..report.html

REM LOGICAL 2 PHYSICAL %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

java -jar %SAXON_JAR% -s:ERA..logical.xml -xsl:%ERHOME%\xslt\ERmodel2.physical.xslt -o:ERA..physical.xml style=hs debug=y

java -jar %SAXON_JAR% -s:ERAdiagrammed..logical.xml -xsl:%ERHOME%\xslt\ERmodel2.physical.xslt -o:ERAdiagrammed..physical.xml style=hs debug=y


REM PHYSICAL DIAGRAMS AND REPORTING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

REM call %ERHOME%\scripts\genSVG ERA..physical..diagram.xml
powershell -Command "%ERHOME%\scripts\genSVG.ps1  ERA..physical..diagram.xml -animate"

REM call %ERHOME%\scripts\genSVG ERAdiagrammed..physical..diagram.xml
powershell -Command "%ERHOME%\scripts\genSVG.ps1  ERAdiagrammed..physical..diagram.xml -animate"

call %ERHOME%\scripts\genHtmlReport ERA..physical.xml
java -jar %SAXON_JAR% -s:ERA..physical..diagram.xml -xsl:%ERHOME%\xslt\ERmodel2.html.xslt -o:..\docs\ERA..physical.report.html

call %ERHOME%\scripts\genHtmlReport ERAdiagrammed..physical.xml

java -jar %SAXON_JAR% -s:ERAdiagrammed..physical..diagram.xml -xsl:%ERHOME%\xslt\ERmodel2.html.xslt -o:..\docs\ERAdiagrammed..physical.report.html

REM generation of xml schema

java -jar %SAXON_JAR% -s:ERA..physical.xml -xsl:%ERHOME%\xslt\ERmodel2.rng.xslt -o:%ERHOME%\schemas\ERA.rng

java -jar %SAXON_JAR% -s:ERAdiagrammed..physical.xml -xsl:%ERHOME%\xslt\ERmodel2.rng.xslt -o:%ERHOME%\schemas\ERAdiagrammed.rng

REM generate xslt's

java -jar %SAXON_JAR% -s:ERA..physical.xml -xsl:%ERHOME%\xslt\ERmodel2.elaboration_xslt.xslt -o:%ERHOME%\xslt\ERmodelERmodel.elaboration.xslt

java -jar %SAXON_JAR% -s:ERA..physical.xml -xsl:%ERHOME%\xslt\ERmodel2.referential_integrity_xslt.xslt -o:%ERHOME%\xslt\ERmodelERmodel.referential_integrity.xslt