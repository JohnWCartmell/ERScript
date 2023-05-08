. ..\buildscripts\setBuildtimePathVariables.ps1

echo ("*** building from  $SOURCE ERValidationTesting folder")

$SOURCEXML = $SOURCE + '\ERValidationTesting'
$TARGETXML = $TARGET + '\ERValidationTesting'


# CREATE target folder if it doesn't already exist
If(!(test-path -PathType container $TARGETXML))
{
      echo ('CREATING target folder ' + $TARGETXML)
      New-Item -ItemType Directory -Path $TARGETXML
}

# COPY xml files
attrib -R $TARGETXML\*.xml
copy-item -Path $SOURCEXML\*.xml -Destination $TARGETXML

pushd $TARGETXML
echo 'Run ER.instanceValidation.xslt'
#. $TARGET\scripts\ER.instanceValidation.ps1 cricketInstance.xml
#. $TARGET\scripts\ER.instanceValidation.ps1 cricketMatch..physical.xml
. $TARGET\scripts\ER.instanceValidation.ps1 ERA..physical.xml

popd 

attrib +R $TARGETXML\*.xml

