$commandFolder=Split-Path $MyInvocation.MyCommand.Path

. ($commandFolder + '\..\..\buildscripts\setBuildtimePathVariables.ps1')

$SOURCEFLEXDIAGRAMMING = $SOURCE + '\flexDiagramming'
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
attrib -R $TARGETXML\*..physical.xml  # these generated and therefore need be overwriteable 

pushd $TARGETXML
if ($false)
{
. $TARGET\scripts\buildExampleSVG.ps1 flexDiagram -animate -physicalType hs
}
. $TARGET\scripts\buildExampleSVG.ps1 flexDiagram -animate
if ($false)
{
#echo 'Flex version'
. $TARGET\flexDiagramming\scripts\er2flex2svg.ps1 flexDiagram..logical.xml -animate
}

popd 