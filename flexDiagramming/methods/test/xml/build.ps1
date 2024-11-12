$commandFolder=Split-Path $MyInvocation.MyCommand.Path

. ($commandFolder + '\..\..\..\..\buildscripts\setBuildtimePathVariables.ps1')

echo ("*** building from  $SOURCE methods test xml folder")

$SOURCEXML = $SOURCE + '\flexDiagramming\methods\test\xml'
$TARGETXML = $TARGET + '\flexDiagramming\methods\test\xml'


# CREATE target xml folder if it doesn't already exist
If(!(test-path -PathType container $TARGETXML))
{
      echo ('CREATING target xml folder ' + $TARGETXML)
      New-Item -ItemType Directory -Path $TARGETXML
}

# COPY xml file
attrib -R $TARGETXML\*.xml
copy-item -Path $SOURCEXML\*.xml -Destination $TARGETXML
attrib +R $TARGETXML\*.xml

pushd $TARGETXML
. $TARGET\flexDiagramming\scripts\styles2css.ps1 testFlexStyleDefinitions.xml -outputFolder ../../../../css
popd