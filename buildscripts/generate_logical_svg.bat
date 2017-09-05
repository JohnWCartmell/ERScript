
call %~dp0\set_path_variables

java -jar %SAXON_PATH%\saxon9he.jar -s:%SRCXML%\ERmodelERmodel.xml -xsl:%XSLT%/ERmodel2.svg.xslt -o:%DOCS%/ERmodel.logical.svg filestem=ERmodel.logical
