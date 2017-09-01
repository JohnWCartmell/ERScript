
call %~dp0\set_path_variables

java -jar %SAXON_PATH%\saxon9he.jar -s:ERmodelERmodel.xml -xsl:%SRC%/ERmodel2.physical.xslt -o:%TEMP%\xml\ERmodelERmodel.physical.xml style=hs

java -jar %SAXON_PATH%\saxon9he.jar -s:%TEMP%\xml\ERmodelERmodel.physical.xml -xsl:%SRC%/ERmodel2.rng.xslt -o:%SCHEMAS%\ERmodel.rng

java -jar %SAXON_PATH%\saxon9he.jar -s:%TEMP%\xml\ERmodelERmodel.physical.xml -xsl:%SRC%/ERmodel2.elaboration_xslt.xslt -o:%SCHEMAS%\ERmodelERmodel.elaboration.xslt

java -jar %SAXON_PATH%\saxon9he.jar -s:%TEMP%\xml\ERmodelERmodel.physical.xml -xsl:%SRC%/ERmodel2.referential_integrity_xslt.xslt -o:%SCHEMAS%\ERmodelERmodel.referential_integrity.xslt

java -jar %SAXON_PATH%\saxon9he.jar -s:%TEMP%\xml\ERmodelERmodel.physical.xml -xsl:%SRC%/ERmodel2.svg.xslt -o:../docs/ERmodel.physical.svg filestem=ERmodel.physical
