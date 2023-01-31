. ..\buildscripts\setBuildtimePathVariables.ps1

echo ("*** building from  $SOURCE metaModel folder")

$SOURCEXML = $SOURCE + '\metaModel'
$TARGETXML = $TARGET + '\metaModel\xml'


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
attrib -R $TARGETXML\*..physical.xml  #therse are generated therefore need be overwritable

pushd $TARGETXML

echo 'ERA'
. $TARGET\scripts\buildExampleSVG.ps1 ERA -animate -physicalType hs

echo 'ERA Diagrammed'
. $TARGET\scripts\buildExampleSVG.ps1 ERAdiagrammed -animate -physicalType hs

echo 'ERA Flex version'
. $TARGET\flexDiagramming\scripts\er2flex2svg.ps1 ERA..logical.xml -animate

popd 



