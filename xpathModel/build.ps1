. ..\buildscripts\setBuildtimePathVariables.ps1

echo ("*** building from  $SOURCE css folder")

$SOURCEXML = $SOURCE + '\xpathModel'
$TARGETXML = $TARGET + '\xpathModel\xml'


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


echo 'xpath Example'

echo generate rng
. $TARGET\scripts\er2.rng.ps1 xpath  -outputFolder ..\bin -debugSwitch

echo 'Run surface ER.instanceValidation.xslt on logical model'
. $TARGET\scripts\ER.instanceValidation.ps1 xpath..logical.xml -outputFolder ..\docs

echo 'build physical model'
. $TARGET\scripts\ER.logical2physical.ps1 xpath -physicalType hs


echo 'Run ER.instanceValidation.xslt on physical model'
. $TARGET\scripts\ER.instanceValidation.ps1 xpath..physical.xml -outputFolder ..\docs


if ($false)
{
 . $TARGET\flexDiagramming\scripts\er2flex2svg.ps1 xpath..logical.xml -animate -debugswitch

}

popd 



