$commandFolder=Split-Path $MyInvocation.MyCommand.Path

. ($commandFolder + '\..\..\buildscripts\setBuildtimePathVariables.ps1')

echo ("*** building from   $SOURCE css folder")


$SOURCESCRIPTS = $SOURCE + '\documentSupport\css'
$TARGETSCRIPTS = $TARGET + '\css' 

# CREATE target scripts folder if it doesn't already exist
If(!(test-path -PathType container $TARGETSCRIPTS))
{
      echo ('CREATING target scripts folder ' + $TARGETSCRIPTS)
      New-Item -ItemType Directory -Path $TARGETSCRIPTS
}

# COPY xslt scripts 
attrib -R $TARGETSCRIPTS\*.css
copy-item -Path $SOURCESCRIPTS\*.css -Destination $TARGETSCRIPTS
attrib +R $TARGETSCRIPTS\*.css

