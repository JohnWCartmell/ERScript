$commandFolder=Split-Path $MyInvocation.MyCommand.Path

. ($commandFolder + '\..\..\buildscripts\setBuildtimePathVariables.ps1')

echo ("*** building from  $SOURCE css folder")

$SOURCEXML = $SOURCE + '\examplesSelected\grids'
$TARGETXML = $TARGET + '\examplesSelected\grids\xml'
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

echo 'grid Example'
if ($false)
{
echo 'Run surface ER.instanceValidation.xslt on logical model'
. $TARGET\scripts\ER.instanceValidation.ps1 grids..logical.xml -outputFolder ..\docs
echo 'build logical and physical model'
. $TARGET\scripts\buildExampleSVG.ps1 grids `
                             -svgOutputFolder $TARGETSVGFOLDER `
                             -texOutputFolder $TARGETTEXFOLDER `
                              -animate -physicalType hs -shortSeparator _ -longSeparator _ -legacy
}
if ($false)
{
echo 'Run ER.instanceValidation.xslt on physical model'
. $TARGET\scripts\ER.instanceValidation.ps1 grids..physical.xml -outputFolder ..\docs
}

#if ($false)
#{
echo 'grids Raw flex version'
. $TARGET\flexDiagramming\scripts\er2svg.ps1 grids..logical.xml -animate

echo 'grids Adjusted flex version'
. $TARGET\flexDiagramming\scripts\er2svg.ps1 grids..diagram.xml -animate

echo 'grids physical Adjusted flex version'
. $TARGET\flexDiagramming\scripts\er2svg.ps1 grids..physical..diagram.xml -animate
#}

popd 



