$commandFolder=Split-Path $MyInvocation.MyCommand.Path

. ($commandFolder + '\..\..\buildscripts\setBuildtimePathVariables.ps1')

echo ("*** building from  $SOURCE XML  folder")

$SOURCEXML = $SOURCE + '\examplesSelected\cricket'
$TARGETXML = $TARGET + '\examplesSelected\cricket\xml'
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
echo 'Cricket Example'

if ($false)
{
echo 'Run surface ER.instanceValidation.xslt on logical model'
. $TARGET\scripts\ER.instanceValidation.ps1 cricketMatch..logical.xml -outputFolder ..\docs

echo 'Cricket Example'
. $TARGET\scripts\buildExampleSVG.ps1 cricketMatch   `
                             -svgOutputFolder $TARGETSVGFOLDER `
                             -texOutputFolder $TARGETTEXFOLDER `
 -animate  -physicalType hs -shortSeparator NA -longSeparator NA 

echo 'Run ER.instanceValidation.xslt on physical model'
. $TARGET\scripts\ER.instanceValidation.ps1 cricketMatch..physical.xml -outputFolder ..\docs -debugSwitch

echo 'Run ER.instanceValidation.xslt on valid instance'
. $TARGET\scripts\ER.instanceValidation.ps1 validCricketInstance.xml -outputFolder ..\docs

echo 'Run ER.instanceValidation.xslt on *invalid* instance'
. $TARGET\scripts\ER.instanceValidation.ps1 invalidCricketInstance.xml -outputFolder ..\docs
}
echo 'Cricket Flex version'
. $TARGET\flexDiagramming\scripts\er2flex2svg.ps1 cricketMatch..logical.xml -animate -debugswitch



popd 



