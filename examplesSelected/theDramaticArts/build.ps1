$commandFolder=Split-Path $MyInvocation.MyCommand.Path

. ($commandFolder + '\..\..\buildscripts\setBuildtimePathVariables.ps1')

echo ("*** building from  $SOURCE theDramaticArts folder")

$SOURCEXML = $SOURCE + '\examplesSelected\theDramaticArts'
$TARGETXML = $TARGET + '\examplesSelected\theDramaticArts\xml'
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



echo 'theDramaticArts Example'
. $TARGET\scripts\buildExampleSVG.ps1 dramaticArts1       `
                             -svgOutputFolder $TARGETSVGFOLDER `
                             -texOutputFolder $TARGETTEXFOLDER `
                             -animate -shortSeparator NA -longSeparator NA
#if ($false)
#{
echo 'theDramaticArts Flex version'
. $TARGET\flexDiagramming\scripts\er2flex2svg.ps1 dramaticArts1..logical.xml -animate
#}

popd 



