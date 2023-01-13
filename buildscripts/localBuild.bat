REM *************************************
REM build command used from sublime text
REM *************************************

SET runlocalbuildcommand=%cd%\build.ps1
echo command is %runlocalbuildcommand%
powershell -Command %runlocalbuildcommand%