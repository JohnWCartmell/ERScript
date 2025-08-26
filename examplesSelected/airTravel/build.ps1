$commandFolder=Split-Path $MyInvocation.MyCommand.Path

. ($commandFolder + '\..\..\buildscripts\setBuildtimePathVariables.ps1')

echo ("*** building from  $SOURCE airTravel folder")

$SOURCEXML = $SOURCE + '\examplesSelected\airTravel'
$TARGETXML = $TARGET + '\examplesSelected\airTravel\xml'
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
echo 'airTravel Example'
echo 'Run surface ER.instanceValidation.xslt on logical model'
. $TARGET\scripts\ER.instanceValidation.ps1 airTravel..logical.xml -outputFolder ..\docs
      
echo 'airTravel Example'
. $TARGET\scripts\buildExampleSVG.ps1 airTravel       `
                             -svgOutputFolder $TARGETSVGFOLDER `
                             -texOutputFolder $TARGETTEXFOLDER `
                             -animate -shortSeparator NA -longSeparator NA  -legacy  

echo 'airTravel Barker Figure 3-18 '
. $TARGET\scripts\buildExampleSVG.ps1 airTravelBarkerFigure3-18       `
                             -svgOutputFolder $TARGETSVGFOLDER `
                             -texOutputFolder $TARGETTEXFOLDER `
                             -animate -shortSeparator NA -longSeparator NA
}

echo 'airTravel Flex version'
. $TARGET\flexDiagramming\scripts\er2svg.ps1 airTravel..logical.xml -animate -debugSwitch

echo 'airTravel Adjusted Flex version'
. $TARGET\flexDiagramming\scripts\er2svg.ps1 airTravel..diagram.xml -animate -debugSwitch

popd 


