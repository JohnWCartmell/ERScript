@echo off

set filepath=%~dp1
set filename=%~nx1
set filenamebase=%filename:~0,-4%

set outputfolder=%2


call %~dp0\set_path_variables

echo "Copying source svg files"
xcopy %filepath%svg %outputfolder%\svg\  /q /y
xcopy %ERHOME%\exampleDataModels\docs %outputfolder%\svg\ /q /y
xcopy %ERHOME%\examplesConceptual\docs %outputfolder%\svg\ /q /y

echo "copy .htaccess.txt"
copy %filepath%.htaccess.txt %outputfolder%\.htaccess.txt

java -jar %SAXON_JAR% -s:"%filepath%%filenamebase%.xml" -xsl:%ERHOME%\xslt\documentERmodel.elaboration.xslt -o:temp\%filenamebase%.elaborated.xml

java -jar %SAXON_JAR% -s:temp\%filenamebase%.elaborated.xml -xsl:%ERHOME%\documentSupport\xslt\documentERmodel.complete.xslt -o:temp\%filenamebase%.completed.xml

java -jar %JING_PATH%\jing.jar -f %ERHOME%\documentModel\schemas\documentERmodel.rng temp\%filenamebase%.completed.xml
