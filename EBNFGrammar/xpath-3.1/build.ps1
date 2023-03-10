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
attrib +R $TARGETXML\*.xml

pushd $TARGETXML
. $TARGET\scripts\EBNF.scraped2grammar.ps1 xpath-3.1.EBNF.xml

. $TARGET\scripts\EBNF.grammar2IDLisation.ps1 xpath-3.1.EBNF.grammar.xml

. $TARGET\scripts\EBNF.test.ps1 xpath-3.1.test.xml -outputFolder docs
popd 

