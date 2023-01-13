@ECHO OFF
set filename=%1
set filenamebase=%filename:~0,-4%

call %~dp0\set_path_variables

java -jar %JING_PATH%\jing.jar -f %DIAGRAM_SCHEMAS%\diagram.rng %1



