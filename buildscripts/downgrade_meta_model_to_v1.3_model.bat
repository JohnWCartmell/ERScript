
rem call %~dp0\set_path_variables

java -jar %SAXON_PATH%\saxon9he.jar -s:%SRCXML%\ERmodelERmodel.xml -xsl:%XSLT%/ERmodel_v1.4_to_ERmodel_v1.3.xslt -o:%XML%\ERmodelERmodel_downgraded_to_v1.3.xml 
