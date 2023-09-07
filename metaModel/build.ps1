. ..\buildscripts\setBuildtimePathVariables.ps1

echo ("*** building from  $SOURCE metaModel folder")

$SOURCEXML = $SOURCE + '\metaModel'
$TARGETXML = $TARGET + '\metaModel\xml'
$TARGETSVGFOLDER = $TARGET + '\www.entitymodelling.org\svg'


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

echo 'ERA.surface'
. $TARGET\scripts\buildExampleSVG.ps1 ERA.surface -svgOutputFolder $TARGETSVGFOLDER -animate -physicalType hs -longSeparator ... -shortSeparator .


echo 'Run surface ER.instanceValidation.xslt on logical model'
. $TARGET\scripts\ER.instanceValidation.ps1 ERA.surface..logical.xml -outputFolder ..\docs

echo 'ERA'
. $TARGET\scripts\buildExampleSVG.ps1 ERA -animate -svgOutputFolder $TARGETSVGFOLDER -physicalType hs -longSeparator ... -shortSeparator . 

echo 'ERScript'
. $TARGET\scripts\buildExampleSVG.ps1 ERScript -svgOutputFolder $TARGETSVGFOLDER -animate -physicalType hs -longSeparator ... -shortSeparator . 

echo 'Run ER.instanceValidation.xslt on ERA physical model'
. $TARGET\scripts\ER.instanceValidation.ps1 ERA..physical.xml -outputFolder ..\docs -debugSwitch

echo 'Run ER.instanceValidation.xslt on ERScript physical model'
. $TARGET\scripts\ER.instanceValidation.ps1 ERScript..physical.xml -outputFolder ..\docs -debugSwitch

echo 'run genSVG.ps1 pullback_constraint.projection_rel..primary_scope.xml'
. $TARGET\scripts\genSVG.ps1 pullback_constraint.projection_rel..primary_scope.xml -outputFolder $TARGETSVGFOLDER

echo 'run genSVG.ps1 pullback_constraint.projection_rel..auxiliary_scope.xml'
. $TARGET\scripts\genSVG.ps1 pullback_constraint.projection_rel..auxiliary_scope.xml -outputFolder $TARGETSVGFOLDER

echo 'run genSVG.ps1 reference.inverse..primary_scope.xml'
. $TARGET\scripts\genSVG.ps1 reference.inverse..primary_scope.xml -outputFolder $TARGETSVGFOLDER

echo 'run genSVG.ps1 reference.inverse..auxiliary_scope.xml'
. $TARGET\scripts\genSVG.ps1 reference.inverse..auxiliary_scope.xml -outputFolder $TARGETSVGFOLDER

echo 'run genSVG.ps1 composition.inverse..primary_scope.xml'
. $TARGET\scripts\genSVG.ps1 composition.inverse..primary_scope.xml -outputFolder $TARGETSVGFOLDER

echo 'run genSVG.ps1 composition.inverse..auxiliary_scope.xml'
. $TARGET\scripts\genSVG.ps1 composition.inverse..auxiliary_scope.xml -outputFolder $TARGETSVGFOLDER

echo 'run genSVG.ps1 step.direction..auxiliary_scope.xml'
. $TARGET\scripts\genSVG.ps1 step.direction..auxiliary_scope.xml -outputFolder $TARGETSVGFOLDER

echo 'run genSVG.ps1 reference_constraint.supported_relationship..primary_scope.xml'
. $TARGET\scripts\genSVG.ps1 reference_constraint.supported_relationship..primary_scope.xml -outputFolder $TARGETSVGFOLDER


echo 'ERA Diagrammed'
. $TARGET\scripts\buildExampleSVG.ps1 ERAdiagrammed -svgOutputFolder $TARGETSVGFOLDER -animate -physicalType hs -longSeparator ... -shortSeparator .

if ($false)
{
echo 'ERA Flex version'
. $TARGET\flexDiagramming\scripts\er2flex2svg.ps1 ERA..logical.xml -animate
}
popd 



