$commandFolder=Split-Path $MyInvocation.MyCommand.Path

. ($commandFolder + '\..\..\buildscripts\setBuildtimePathVariables.ps1')

echo ("*** building from  $SOURCE css folder")

$SOURCEXML = $SOURCE + '\examplesSelected\chromatogramAnalysisRecord'
$TARGETXML = $TARGET + '\examplesSelected\chromatogramAnalysisRecord\xml'


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

if ($false)
{
echo 'chromatogram Example'
echo 'Run surface ER.instanceValidation.xslt on logical model'
. $TARGET\scripts\ER.instanceValidation.ps1 chromatogram_analysis_record..logical.xml -outputFolder ..\docs
}

##################################################################################
# NOTE that the physicalType is 'h' (I know this from looking at an old printout).
##################################################################################
echo 'build physical model'
. $TARGET\scripts\buildExampleSVG.ps1 chromatogram_analysis_record -animate -physicalType h -longSeparator _ -shortSeparator _ 

echo 'Run ER.instanceValidation.xslt on physical model'
. $TARGET\scripts\ER.instanceValidation.ps1 chromatogram_analysis_record..physical.xml -outputFolder ..\docs 

echo 'Run ERModel.2ts.xslt'
. $TARGET\scripts\ER2.ts.ps1 chromatogram_analysis_record..physical.xml -outputFolder ..\typescript -debugswitch


if ($false)
{
echo 'chromatogram_analysis_record Flex version'
. $TARGET\flexDiagramming\scripts\er2flex2svg.ps1 chromatogram_analysis_record..logical.xml -animate
}

popd 



