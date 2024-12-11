$commandFolder=Split-Path $MyInvocation.MyCommand.Path

. ($commandFolder + '\..\..\buildscripts\setBuildtimePathVariables.ps1')

echo ("*** building from  $SOURCE shlaer-lang folder")

$SOURCEXML = $SOURCE + '\examplesSelected\shlaer-lang'
$TARGETXML = $TARGET + '\examplesSelected\shlaer-lang\xml'
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

echo 'shlaer-lang Example'
echo 'Run surface ER.instanceValidation.xslt on logical model'
. $TARGET\scripts\ER.instanceValidation.ps1 shlaerMellorDeptStudentProfessor0..logical.xml -outputFolder ..\docs

echo 'shlaer-lang Example'
. $TARGET\scripts\buildExampleSVG.ps1 shlaerMellorDeptStudentProfessor0       `
                             -svgOutputFolder $TARGETSVGFOLDER `
                             -texOutputFolder $TARGETTEXFOLDER `
                             -debugSwitch `
                             -animate -shortSeparator NA -longSeparator NA
#if ($false)
#{
echo 'shlaer-lang Flex version'
. $TARGET\flexDiagramming\scripts\er2flex2svg.ps1 shlaerMellorDeptStudentProfessor0..logical.xml -animate
#}

popd 



