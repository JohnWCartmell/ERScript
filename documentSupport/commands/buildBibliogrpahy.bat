echo %cd%
java -jar ..\2015xslt\saxon\SaxonHE9-6-0-7J\saxon9he.jar -s:../SharedBibliography/src/bibliography.xml -xsl:bibliography2.html.xslt -o:./bibliography.html rootpath=. sidebarstem="homesidebar"




