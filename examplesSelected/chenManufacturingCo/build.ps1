$commandFolder=Split-Path $MyInvocation.MyCommand.Path

. ($commandFolder + '\..\..\buildscripts\setBuildtimePathVariables.ps1')

echo ("*** building from  $SOURCE chenManufacturingCo folder")

$SOURCEXML = $SOURCE + '\examplesSelected\chenManufacturingCo'
$TARGETXML = $TARGET + '\examplesSelected\chenManufacturingCo\xml'
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


echo 'chenManufacturingCo Example'
. $TARGET\scripts\buildExampleSVG.ps1 chenManufacturingCo       `
                             -svgOutputFolder $TARGETSVGFOLDER `
                             -texOutputFolder $TARGETTEXFOLDER `
                             -animate -shortSeparator NA -longSeparator NA

 if ($false)
{
echo 'chenManufacturingCo Flex version'
. $TARGET\flexDiagramming\scripts\er2flex2svg.ps1 chenManufacturingCo..logical.xml -animate
}

popd 



