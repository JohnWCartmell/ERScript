
rem call %~dp0\set_path_variables

java -jar %SAXON_JAR% -s:%XML%\ERmodelERmodel.core.diagram.xml -xsl:%XSLT%/ERmodel2.svg.xslt -o:%DOCS%/ERmodel.core.svg filestem=ERmodel.core

java -jar %SAXON_JAR% -s:%XML%\ERmodelERmodel.core.xml -xsl:%XSLT%/ERmodel2.html.xslt -o:%DOCS%/ERmodel.core.report.html