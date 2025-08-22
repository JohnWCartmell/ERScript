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
if ($false)
{
echo 'chenManufacturingCo Example'
. $TARGET\scripts\buildExampleSVG.ps1 chenManufacturingCo       `
                             -svgOutputFolder $TARGETSVGFOLDER `
                             -texOutputFolder $TARGETTEXFOLDER `
                             -animate -shortSeparator NA -longSeparator NA -legacy
echo 'chenManufacturingCo Raw Flex version'
. $TARGET\flexDiagramming\scripts\er2svg.ps1 chenManufacturingCo..logical.xml -animate
}

#if ($false)
#{
echo 'chenManufacturingCo Adjusted Flex version'
. $TARGET\flexDiagramming\scripts\er2svg.ps1 chenManufacturingCo..diagram.xml -animate
#}

popd 



