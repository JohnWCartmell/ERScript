$commandFolder=Split-Path $MyInvocation.MyCommand.Path

. ($commandFolder + '\..\..\buildscripts\setBuildtimePathVariables.ps1')

echo ("*** building from  $SOURCE unitTest folder")

$SOURCEXML = $SOURCE + '\examplesSelected\unitTest'
$TARGETXML = $TARGET + '\examplesSelected\unitTest\xml'
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

echo 'unitTest Example'
if ($false)
{
echo 'Run surface ER.instanceValidation.xslt on logical model'
. $TARGET\scripts\ER.instanceValidation.ps1 unitTest..logical.xml -outputFolder ..\docs

echo 'unitTest Example'
. $TARGET\scripts\buildExampleSVG.ps1 unitTest       `
                             -svgOutputFolder $TARGETSVGFOLDER `
                             -texOutputFolder $TARGETTEXFOLDER `
                             -debugSwitch `
                             -animate -shortSeparator NA -longSeparator NA
}

echo 'unitTest Flex version'
. $TARGET\flexDiagramming\scripts\er2flex2svg.ps1 unitTest..logical.xml -animate

popd 



