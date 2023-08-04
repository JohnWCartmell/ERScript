$commandFolder=Split-Path $MyInvocation.MyCommand.Path

. ($commandFolder + '\..\..\buildscripts\setBuildtimePathVariables.ps1')

echo ("*** SOURCE is  $SOURCE ***")

$SOURCEDOCSUPPORT = $SOURCE + '\documentSupport'
$SOURCEMODEL = $SOURCEDOCSUPPORT + '\documentModel'
$TARGETXML = $TARGET + '\documentModel\xml'

# CREATE target folder if it doesn't already exist
If(!(test-path -PathType container $TARGETXML))
{
      echo ('CREATING target folder ' + $TARGETXML)
      New-Item -ItemType Directory -Path $TARGETXML
}

# COPY xml files
attrib -R $TARGETXML\*.xml
copy-item -Path $SOURCEMODEL\*.xml -Destination $TARGETXML
attrib +R $TARGETXML\*.xml
attrib -R $TARGETXML\*..physical.xml  # these generated and therefore need be overwriteable 

$TARGETXSLTFOLDER = $TARGET + '\xslt\document'
$TARGETSCHEMAFOLDER = $TARGET + '\documentModel\schemas'
pushd $TARGETXML
. $TARGET\scripts\buildLegacySVG.ps1 documentERModel -animate -physicalType hs -longSeparator _ -shortSeparator _ -rng_folder_path $TARGETSCHEMAFOLDER -elaboration_xslt_folder_path $TARGETXSLTFOLDER

if ($false)
{
echo 'Brinton Flex version'
. $TARGET\flexDiagramming\scripts\er2flex2svg.ps1 documentERModel.xml -animate 
}

popd 