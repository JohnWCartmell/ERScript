$commandFolder=Split-Path $MyInvocation.MyCommand.Path

. ($commandFolder + '\..\..\buildscripts\setBuildtimePathVariables.ps1')

echo ("*** building from  $SOURCE css folder")

$SOURCEXML = $SOURCE + '\examplesSelected\orderEntry'
$TARGETXML = $TARGET + '\examplesSelected\orderEntry\xml'
$TARGETSVGFOLDER = $TARGET + '\www.entitymodelling.org\svg'
$TARGETTEXFOLDER = $TARGET + '\docs\images'


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
echo 'orderEntry Example'
if ($false)
{
echo 'Run surface ER.instanceValidation.xslt on logical model'
. $TARGET\scripts\ER.instanceValidation.ps1 orderEntry..logical.xml -outputFolder ..\docs

echo 'orderEntry Example'
. $TARGET\scripts\buildExampleSVG.ps1 orderEntry `
                             -svgOutputFolder $TARGETSVGFOLDER `
                             -texOutputFolder $TARGETTEXFOLDER `
                    -animate -physicalType h -longSeparator ... -shortSeparator .

echo 'Run ER.instanceValidation.xslt on physical model'
. $TARGET\scripts\ER.instanceValidation.ps1 orderEntry..physical.xml -outputFolder ..\docs -debugSwitch


echo 'Run ER.instanceValidation.xslt on valid instance'
. $TARGET\scripts\ER.instanceValidation.ps1 validorderEntryInstance.xml -outputFolder ..\docs -debugSwitch
}
echo 'orderEntry Flex version'
. $TARGET\flexDiagramming\scripts\er2flex2svg.ps1 orderEntry..logical.xml -animate 

popd 



