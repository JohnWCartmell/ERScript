$commandFolder=Split-Path $MyInvocation.MyCommand.Path

. ($commandFolder + '\..\..\buildscripts\setBuildtimePathVariables.ps1')

echo ("*** building from  $SOURCE css folder")

$SOURCEXML = $SOURCE + '\examplesSelected\grids'
$TARGETXML = $TARGET + '\examplesSelected\grids\xml'


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

echo 'grid Example'
echo 'Run surface ER.instanceValidation.xslt on logical model'
. $TARGET\scripts\ER.instanceValidation.ps1 grids..logical.xml -outputFolder ..\docs

echo 'build physical model'
. $TARGET\scripts\buildExampleSVG.ps1 grids -animate -physicalType hs

echo 'Run ER.instanceValidation.xslt on physical model'
. $TARGET\scripts\ER.instanceValidation.ps1 grids..physical.xml -outputFolder ..\docs

if ($false)
{
echo 'grids Flex version'
. $TARGET\flexDiagramming\scripts\er2flex2svg.ps1 grids..logical.xml -animate
}

popd 



