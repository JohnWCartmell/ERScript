$commandFolder=Split-Path $MyInvocation.MyCommand.Path

. ($commandFolder + '\..\..\buildscripts\setBuildtimePathVariables.ps1')

echo ("*** building from   $SOURCE scripts powershell folder")

$SOURCEPOWERSHELLSCRIPTS = $SOURCE + '\scripts\powershell'
$TARGETSCRIPTS = $TARGET + '\scripts'

# CREATE target scripts folder if it doesn't already exist
If(!(test-path -PathType container $TARGETSCRIPTS))
{
      echo ('CREATING target scripts folder ' + $TARGETSCRIPTS)
      New-Item -ItemType Directory -Path $TARGETSCRIPTS
}

# COPY powershell scripts 
attrib -R $TARGETSCRIPTS\*.ps1
copy-item -Path $SOURCEPOWERSHELLSCRIPTS\*.ps1 -Destination $TARGETSCRIPTS
attrib +R $TARGETSCRIPTS\*.ps1
