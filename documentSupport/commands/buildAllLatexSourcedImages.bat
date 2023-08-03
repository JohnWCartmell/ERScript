@echo off

set latexSourceDir=%1
set targetImageDir=%2

SETLOCAL ENABLEDELAYEDEXPANSION


if not exist temp mkdir temp


FOR %%t IN (%latexSourceDir%\*.tex) DO (
  set filename=%%t

  echo           **** generating image from tex: !filename!
  call %~dp0buildImage %%t %targetImageDir%
  echo. 
)
