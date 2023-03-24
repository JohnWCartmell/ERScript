. ..\..\buildscripts\setBuildtimePathVariables.ps1

echo ("*** building from  $SOURCE EBNF xpath-3.1 folder")

$SOURCEXML = $SOURCE + '\EBNFGrammar\xpath-3.1'
$TARGETXML = $TARGET + '\EBNFGrammar\xpath-3.1'


# CREATE target folder if it doesn't already exist
If(!(test-path -PathType container $TARGETXML))
{
      echo ('CREATING target folder ' + $TARGETXML)
      New-Item -ItemType Directory -Path $TARGETXML
}

# COPY xml files
attrib -R $TARGETXML\*.xml
copy-item -Path $SOURCEXML\*.xml -Destination $TARGETXML


pushd $TARGETXML
echo 'Run EBNF.scraped2grammar.xslt'
. $TARGET\scripts\EBNF.scraped2grammar.ps1 xpath-3.1.EBNF.xml

echo 'Run EBNF.grammar2IDLisation.xslt'
. $TARGET\scripts\EBNF.grammar2IDLisation.ps1 xpath-3.1.EBNF.grammar.xml

echo 'Run EBNF.test.xslt'
. $TARGET\scripts\EBNF.test.ps1 xpath-3.1.test.xml -outputFolder docs

java -jar $JING_PATH\jing.jar -f $TARGET\xpathModel\bin\xpath..physical.rng docs/xpath-3.1.test.parseout.xml

popd 

attrib +R $TARGETXML\*.xml

