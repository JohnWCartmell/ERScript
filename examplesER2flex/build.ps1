. ..\buildscripts\setBuildtimePathVariables.ps1

echo ("*** building from  $SOURCE css folder")

$SOURCEXML = $SOURCE + '\examplesER2flex'
$TARGETXML = $TARGET + '\examplesER2flex\xml'


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


echo 'Quadrant Route Test'
. $TARGET\flexDiagramming\scripts\er2flex2svg.ps1 quadrant_routes..logical.xml -animate -debugswitch


popd 



