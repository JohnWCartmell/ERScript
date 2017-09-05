
@echo off

call %~dp0\set_path_variables

if not exist %TARGETDIR% mkdir %TARGETDIR%
if not exist %TARGETDIR%\xml mkdir %TARGETDIR%\xml
if not exist %TARGETDIR%\temp mkdir %TARGETDIR%\temp
if not exist %TARGETDIR%\xslt mkdir %TARGETDIR%\xslt
if not exist %TARGETDIR%\docs mkdir %TARGETDIR%\docs
if not exist %TARGETDIR%\schemas mkdir %TARGETDIR%\schemas
if not exist %TARGETDIR%\logs mkdir %TARGETDIR%\logs

rem for %%x in (%SRCXSLT%\*) do copy %%x %TARGETDIR%\%%x
xcopy %SRCDIR%\xslt %TARGETDIR%\xslt\
xcopy %SRCDIR%\examplesConceptual %DISTRIBUTION%\examplesConceptual\
xcopy %SRCDIR%\exampleDataModels %DISTRIBUTION%\exampleDataModels\

call %~dp0\generate



  