$commandFolder=Split-Path $MyInvocation.MyCommand.Path

. ($commandFolder + '\..\..\..\..\buildscripts\setBuildtimePathVariables.ps1')

echo ("*** building from  $SOURCE methods era js folder")

$SOURCEJS = $SOURCE + '\flexDiagramming\methods\era\js'
$TARGETJS = $TARGET + '\js'

echo ('SOURCEJS ' + $SOURCEJS)

# CREATE target js folder if it doesn't already exist
If(!(test-path -PathType container $TARGETJS))
{
      echo ('CREATING target js folder ' + $TARGETJS)
      New-Item -ItemType Directory -Path $TARGETJS
}

# COPY js file
attrib -R $TARGETJS\*.js
copy-item -Path $SOURCEJS\*.js -Destination $TARGETJS
attrib +R $TARGETJS\*.js
