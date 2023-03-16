. ..\buildscripts\setBuildtimePathVariables.ps1

echo ("*** building from  $SOURCE css folder")

$SOURCEXML = $SOURCE + '\xpathModel'
$TARGETXML = $TARGET + '\xpathModel\xml'


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
#attrib -R $TARGETXML\*..physical.xml    #these are generated and therefore need to be overwriteable

pushd $TARGETXML

. $TARGET\flexDiagramming\scripts\er2flex2svg.ps1 xpath..logical.xml -animate

popd 



