$commandFolder=Split-Path $MyInvocation.MyCommand.Path

. ($commandFolder + '\..\..\buildscripts\setBuildtimePathVariables.ps1')

echo ("*** building from  $SOURCE goodlandSSADMcarHire folder")

$SOURCEXML = $SOURCE + '\examplesSelected\goodlandSSADMcarHire'
$TARGETXML = $TARGET + '\examplesSelected\goodlandSSADMcarHire\xml'
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

echo 'goodlandSSADMcarHire Example'
echo 'Run surface ER.instanceValidation.xslt on logical model'
. $TARGET\scripts\ER.instanceValidation.ps1 goodlandSSADMcarHire..logical.xml -outputFolder ..\docs

echo 'goodland SSADM carHire'
. $TARGET\scripts\buildExampleSVG.ps1 goodlandSSADMcarHire       `
                             -svgOutputFolder $TARGETSVGFOLDER `
                             -texOutputFolder $TARGETTEXFOLDER `
                             -animate -relids -shortSeparator NA -longSeparator NA 

if ($false)
{
echo 'goodland SSADM carHire Flex version'
. $TARGET\flexDiagramming\scripts\er2flex2svg.ps1 goodlandSSADMcarHire..logical.xml -animate
}

popd 



