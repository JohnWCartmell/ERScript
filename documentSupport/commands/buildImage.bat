@echo off

set filepath=%~dp1
set filename=%~nx1
set filenamebase=%filename:~0,-4%

set targetImageDir=%2

 echo           **** targetImageDir: %targetImageDir%

call %~dp0\set_path_variables

call %ERSCRIPTHOME%\commands\set_path_variables

powershell %~dp0\generate_main_tex.ps1 -imageSourceFilePath %1 -docHome %DOCHOME% -ERHome %ERHOME%

cd temp
latex %filename%
dvips -P pdf %filenamebase%.dvi
ps2pdf %filenamebase%.ps
cd ..
convert -density 1000x1000 temp\%filenamebase%.pdf -quality 95 %targetImageDir%\%filenamebase%.png

 echo           **** targetImageDir: %targetImageDir%






