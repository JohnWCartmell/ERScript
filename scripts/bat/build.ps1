$commandFolder=Split-Path $MyInvocation.MyCommand.Path

. ($commandFolder + '\..\..\buildscripts\setBuildtimePathVariables.ps1')

echo ("*** building from   $SOURCE scripts bat folder")


$SOURCEBATSCRIPTS = $SOURCE + '\scripts\bat'
$TARGETSCRIPTS = $TARGET + '\scripts'

# CREATE target scripts folder if it doesn't already exist
If(!(test-path -PathType container $TARGETSCRIPTS))
{
      echo ('CREATING target scripts folder ' + $TARGETSCRIPTS)
      New-Item -ItemType Directory -Path $TARGETSCRIPTS
}

# COPY bat scripts 
attrib -R $TARGETSCRIPTS\*.bat
copy-item -Path $SOURCEBATSCRIPTS\*.bat -Destination $TARGETSCRIPTS
attrib +R $TARGETSCRIPTS\*.bat
