


$SOURCEMODEL = $SOURCEFLEXDIAGRAMMING + '\flexDiagramModel'
$TARGETXML = $TARGET + '\flexDiagramModel\xml'


# CREATE target folder if it doesn't already exist
If(!(test-path -PathType container $TARGETXML))
{
      echo ('CREATING target folder ' + $TARGETXML)
      New-Item -ItemType Directory -Path $TARGETXML
}

# COPY xml files
attrib -R $TARGETXML\*.xml
copy-item -Path $SOURCEMODEL\*.xml -Destination $TARGETXML
attrib +R $TARGETXML\*.xml

pushd $TARGETXML
. $TARGET\scripts\buildExampleSVG.ps1 flexDiagram -animate -physicalType hs
popd 