
call %~dp0\set_path_variables

java -jar %SAXON_PATH%\saxon9he.jar -s:%SRCXML%\ERmodelERmodel.xml -xsl:%XSLT%/ERmodel2.physical.xslt -o:%XML%\ERmodelERmodel.physical.xml style=hs

java -jar %SAXON_PATH%\saxon9he.jar -s:%XML%\ERmodelERmodel.physical.xml -xsl:%XSLT%/ERmodel2.rng.xslt -o:%SCHEMAS%\ERmodel.rng

java -jar %SAXON_PATH%\saxon9he.jar -s:%XML%\ERmodelERmodel.physical.xml -xsl:%XSLT%/ERmodel2.elaboration_xslt.xslt -o:%XSLT%\ERmodelERmodel.elaboration.xslt

java -jar %SAXON_PATH%\saxon9he.jar -s:%XML%\ERmodelERmodel.physical.xml -xsl:%XSLT%/ERmodel2.referential_integrity_xslt.xslt -o:%XSLT%\ERmodelERmodel.referential_integrity.xslt

java -jar %SAXON_PATH%\saxon9he.jar -s:%XML%\ERmodelERmodel.physical.xml -xsl:%XSLT%/ERmodel2.svg.xslt -o:%DOCS%/ERmodel.physical.svg filestem=ERmodel.physical
