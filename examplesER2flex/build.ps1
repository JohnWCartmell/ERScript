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



. $TARGET\flexDiagramming\scripts\er2flex2svg.ps1 x1Test..logical.xml -animate -debugswitch
if ($false)
{
. $TARGET\flexDiagramming\scripts\er2flex2svg.ps1 nestedShieldedDecomposition..logical.xml -animate -debugswitch
. $TARGET\flexDiagramming\scripts\er2flex2svg.ps1 complexRecursion..logical.xml -animate -debugswitch
. $TARGET\flexDiagramming\scripts\er2flex2svg.ps1 simpleRecursion..logical.xml -animate -debugswitch
. $TARGET\flexDiagramming\scripts\er2flex2svg.ps1 simpleDecomposition..logical.xml -animate -debugswitch
. $TARGET\flexDiagramming\scripts\er2flex2svg.ps1 shieldedDecomposition..logical.xml -animate -debugswitch
echo 'Quadrant Route Test'
. $TARGET\flexDiagramming\scripts\er2flex2svg.ps1 quadrant_routes..logical.xml -animate -debugswitch
}

popd 



