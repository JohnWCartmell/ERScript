$commandFolder=Split-Path $MyInvocation.MyCommand.Path

. ($commandFolder + '\..\..\buildscripts\setBuildtimePathVariables.ps1')

echo ("*** building from  $SOURCE css folder")

$SOURCEXML = $SOURCE + '\examplesSelected\brinton'
$TARGETXML = $TARGET + '\examplesSelected\brinton\xml'


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

echo 'Brinton Example'
echo 'Run surface ER.instanceValidation.xslt on logical model'
. $TARGET\scripts\ER.instanceValidation.ps1 brintonSimpleSentenceStructure..logical.xml -outputFolder ..\docs

echo 'Brinton Example'
. $TARGET\scripts\buildExampleSVG.ps1 brintonSimpleSentenceStructure -animate

echo 'Run ER.instanceValidation.xslt on physical model'
. $TARGET\scripts\ER.instanceValidation.ps1 brintonSimpleSentenceStructure..physical.xml -outputFolder ..\docs
 if ($false)
{
echo 'Brinton Flex version'
. $TARGET\flexDiagramming\scripts\er2flex2svg.ps1 brintonSimpleSentenceStructure..logical.xml -animate
}

popd 



