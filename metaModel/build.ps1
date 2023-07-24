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

if ($false)
{
echo 'ERA.surface'
. $TARGET\scripts\buildExampleSVG.ps1 ERA.surface -animate -physicalType hs -longSeparator ... -shortSeparator .

echo 'Run surface ER.instanceValidation.xslt on logical model'
. $TARGET\scripts\ER.instanceValidation.ps1 ERA.surface..logical.xml -outputFolder ..\docs


echo 'ERA'
. $TARGET\scripts\buildExampleSVG.ps1 ERA -animate -physicalType hs -longSeparator ... -shortSeparator . 

echo 'ERScript'
. $TARGET\scripts\buildExampleSVG.ps1 ERScript -animate -physicalType hs -longSeparator ... -shortSeparator . 


echo 'Run ER.instanceValidation.xslt on ERA physical model'
. $TARGET\scripts\ER.instanceValidation.ps1 ERA..physical.xml -outputFolder ..\docs -debugSwitch

echo 'Run ER.instanceValidation.xslt on ERScript physical model'
. $TARGET\scripts\ER.instanceValidation.ps1 ERScript..physical.xml -outputFolder ..\docs -debugSwitch
}


if ($false)
{
echo 'run genSVG.ps1 pullback.projection_rel..primary_scope.xml'
. $TARGET\scripts\genSVG.ps1 pullback.projection_rel..primary_scope.xml -bundle

echo 'run genSVG.ps1 pullback.projection_rel..auxiliary_scope.xml'
. $TARGET\scripts\genSVG.ps1 pullback.projection_rel..auxiliary_scope.xml -bundle

echo 'run genSVG.ps1 reference.inverse..primary_scope.xml'
. $TARGET\scripts\genSVG.ps1 reference.inverse..primary_scope.xml -bundle

echo 'run genSVG.ps1 reference.inverse..auxiliary_scope.xml'
. $TARGET\scripts\genSVG.ps1 reference.inverse..auxiliary_scope.xml -bundle

echo 'run genSVG.ps1 composition.inverse..primary_scope.xml'
. $TARGET\scripts\genSVG.ps1 composition.inverse..primary_scope.xml -bundle

echo 'run genSVG.ps1 composition.inverse..auxiliary_scope.xml'
. $TARGET\scripts\genSVG.ps1 composition.inverse..auxiliary_scope.xml -bundle
}

echo 'run genSVG.ps1 component.rel..auxiliary_scope.xml'
. $TARGET\scripts\genSVG.ps1 component.rel..auxiliary_scope.xml -bundle


if ($false)
{
echo 'ERA Diagrammed'
. $TARGET\scripts\buildExampleSVG.ps1 ERAdiagrammed -animate -physicalType hs -longSeparator ... -shortSeparator .

echo 'ERA Flex version'
. $TARGET\flexDiagramming\scripts\er2flex2svg.ps1 ERA..logical.xml -animate
}

popd 



