. ..\..\buildscripts\setBuildtimePathVariables.ps1

echo ("*** building from  $SOURCE EBNF folder")

$SOURCEXML = $SOURCE + '\EBNFGrammar\mini-grammar'
$TARGETXML = $TARGET + '\EBNFGrammar\mini-grammar'


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
attrib -R $TARGETXML\*..physical.xml    #these are generated and therefore need to be overwriteable

pushd $TARGETXML
. $TARGET\scripts\EBNF.test.ps1 mini.EBNF.test.xml -outputFolder docs
popd 

