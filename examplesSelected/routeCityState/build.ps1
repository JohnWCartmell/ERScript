$commandFolder=Split-Path $MyInvocation.MyCommand.Path

. ($commandFolder + '\..\..\buildscripts\setBuildtimePathVariables.ps1')

echo ("*** building from  $SOURCE routeCityState folder")

$SOURCEXML = $SOURCE + '\examplesSelected\routeCityState'
$TARGETXML = $TARGET + '\examplesSelected\routeCityState\xml'
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

echo 'routeCityState Example'
if ($false)
{
echo 'Run surface ER.instanceValidation.xslt on logical model'
. $TARGET\scripts\ER.instanceValidation.ps1 routeCityState..logical.xml -outputFolder ..\docs

echo 'routeCityState Example topdown'
. $TARGET\scripts\buildExampleSVG.ps1 routeCityState..topdown       `
                             -svgOutputFolder $TARGETSVGFOLDER `
                             -texOutputFolder $TARGETTEXFOLDER `
                             -animate -shortSeparator NA -longSeparator NA      

echo 'routeCityState Example leftright'
. $TARGET\scripts\buildExampleSVG.ps1 routeCityState..leftright       `
                             -svgOutputFolder $TARGETSVGFOLDER `
                             -texOutputFolder $TARGETTEXFOLDER `
                             -animate -shortSeparator NA -longSeparator NA

echo 'routeCityState Example comparablePaths topdown'
. $TARGET\scripts\buildExampleSVG.ps1 routeCityCityState..topdown       `
                             -svgOutputFolder $TARGETSVGFOLDER `
                             -texOutputFolder $TARGETTEXFOLDER `
                             -animate -shortSeparator NA -longSeparator NA

echo 'routeCityState Example comparablePaths leftright'
. $TARGET\scripts\buildExampleSVG.ps1 routeCityCityState..leftright       `
                             -svgOutputFolder $TARGETSVGFOLDER `
                             -texOutputFolder $TARGETTEXFOLDER `
                             -animate -shortSeparator NA -longSeparator NA
}
#if ($false)
#{
echo 'routeCityState Flex version'
. $TARGET\flexDiagramming\scripts\er2flex2svg.ps1 routeCityState..logical.xml -animate
#}

popd 



