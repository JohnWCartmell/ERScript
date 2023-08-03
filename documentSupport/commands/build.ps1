$commandFolder=Split-Path $MyInvocation.MyCommand.Path

. ($commandFolder + '\..\..\buildscripts\setBuildtimePathVariables.ps1')

echo ("*** building from   $SOURCE command folder")


$SOURCESCRIPTS = $SOURCE + '\documentSupport\commands'
$TARGETSCRIPTS = $TARGET + '\documentSupport\commands' 

# CREATE target scripts folder if it doesn't already exist
If(!(test-path -PathType container $TARGETSCRIPTS))
{
      echo ('CREATING target scripts folder ' + $TARGETSCRIPTS)
      New-Item -ItemType Directory -Path $TARGETSCRIPTS
}

# COPY bat scripts 
attrib -R $TARGETSCRIPTS\*.bat
copy-item -Path $SOURCESCRIPTS\*.bat -Destination $TARGETSCRIPTS
attrib +R $TARGETSCRIPTS\*.bat
# COPY bat scripts 
attrib -R $TARGETSCRIPTS\*.ps1
copy-item -Path $SOURCESCRIPTS\*.ps1 -Destination $TARGETSCRIPTS
attrib +R $TARGETSCRIPTS\*.ps1
