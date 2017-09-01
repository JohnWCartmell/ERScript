
call %~dp0\set_path_variables

java -jar %SAXON_PATH%\saxon9he.jar -s:ERmodelERmodel.xml -xsl:%SRC%/ERmodel2.svg.xslt -o:%ERHOME%/docs/ERmodel.logical.svg filestem=ERmodel.logical
