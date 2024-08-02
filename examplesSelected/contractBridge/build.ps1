$commandFolder=Split-Path $MyInvocation.MyCommand.Path

. ($commandFolder + '\..\..\buildscripts\setBuildtimePathVariables.ps1')

echo ("*** building from  $SOURCE css folder")

$SOURCEXML = $SOURCE + '\examplesSelected\contractBridge\xml'
$SOURCEDOCS = $SOURCE + '\examplesSelected\contractBridge\docs'
$TARGETXML = $TARGET + '\examplesSelected\contractBridge\xml'
$TARGETSVGFOLDER = $TARGET + '\www.entitymodelling.org\svg'
$TARGETTEXFOLDER = $TARGET + '\docs\images'


# CREATE target folder if it doesn't already exist
If(!(test-path -PathType container $TARGETXML))
{
      echo ('CREATING target folder ' + $TARGETXML)
      New-Item -ItemType Directory -Path $TARGETXML
}

# COPY xml files
attrib -R $TARGETXML\*.html
attrib -R $TARGETXML\*.js
attrib -R $TARGETXML\*.css
attrib -R $TARGETXML\*.xml
copy-item -Path $SOURCEDOCS\*.html -Destination $TARGETXML
copy-item -Path $SOURCEDOCS\*.js -Destination $TARGETXML
copy-item -Path $SOURCEDOCS\*.css -Destination $TARGETXML
copy-item -Path $SOURCEXML\*.xml -Destination $TARGETXML
attrib +R $TARGETXML\*.html
attrib +R $TARGETXML\*.js
attrib +R $TARGETXML\*.css
attrib +R $TARGETXML\*.xml


pushd $TARGETXML
echo 'Contract Bridge'
echo 'Flex version'
. $TARGET\flexDiagramming\scripts\er2flex2svg.ps1 thePack..logical.xml -animate

popd 



