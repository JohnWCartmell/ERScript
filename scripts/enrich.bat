@ECHO OFF
set filename=%1
set filenamebase=%filename:~0,-4%

call %~dp0\set_path_variables

java -jar %SAXON_PATH%\saxon9he.jar -s:temp/%filenamebase%.elaborated.xml -xsl:%DIAGRAM_GENERATORS%/diagram2.initial_enrichment.xslt -o:temp/%filenamebase%.enriched.xml maxiter=%2

java -jar %JING_PATH%/jing.jar -f %DIAGRAM_SCHEMAS%/diagram.rng temp/%filenamebase%.enriched.xml


