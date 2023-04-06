. ..\..\..\buildscripts\setBuildtimePathVariables.ps1

echo ("*** building from  $SOURCE EBNF xpath-3.1 reconstruction folder")

$SOURCEXML = $SOURCE + '\EBNFGrammar\xpath-3.1\reconstruction'
$TARGETXML = $TARGET + '\EBNFGrammar\xpath-3.1\reconstruction'


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
echo 'Run EBNF.recontruction.xslt'
. $TARGET\scripts\EBNF.reconstruction.ps1 xpath-3.1.reconstruction.test.xml


popd 

attrib +R $TARGETXML\*.xml
