$commandFolder=Split-Path $MyInvocation.MyCommand.Path

. ($commandFolder + '\..\..\buildscripts\setBuildtimePathVariables.ps1')

echo ("*** building from  $SOURCE css folder")

$SOURCEXML = $SOURCE + '\examplesSelected\relationalMetaModel3'
$TARGETXML = $TARGET + '\examplesSelected\relationalMetaModel3\xml'
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

echo 'Relational Meta Model Example'
if ($false)
{
echo 'Run surface ER.instanceValidation.xslt on logical model'
. $TARGET\scripts\ER.instanceValidation.ps1 relationalMetaModel3..logical.xml -outputFolder ..\docs
}

echo 'Build physical (relational) model'
. $TARGET\scripts\buildExampleSVG.ps1 relationalMetaModel3 `
                             -svgOutputFolder $TARGETSVGFOLDER `
                             -texOutputFolder $TARGETTEXFOLDER `
                              -animate -physicalType r -longSeparator ... -shortSeparator . -legacy
if ($false)
{
echo 'Run ER.instanceValidation.xslt on physical model'
. $TARGET\scripts\ER.instanceValidation.ps1 relationalMetaModel3..physical.xml -outputFolder ..\docs -debugSwitch
}

#if ($false)
#{
echo 'Relational Meta Model raw Flex version'
. $TARGET\flexDiagramming\scripts\er2svg.ps1 relationalMetaModel3..logical.xml -animate -debugswitch

echo 'Relational Meta Model adjusted Flex version'
. $TARGET\flexDiagramming\scripts\er2svg.ps1 relationalMetaModel3..diagram.xml -animate -debugswitch

echo 'Relational Meta Model physical Adjusted Flex version'
. $TARGET\flexDiagramming\scripts\er2svg.ps1 relationalMetaModel3..physical..diagram.xml -animate -debugswitch
#}

popd 



