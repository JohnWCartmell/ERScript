$commandFolder=Split-Path $MyInvocation.MyCommand.Path

. ($commandFolder + '\..\buildscripts\setBuildtimePathVariables.ps1')


echo ("*** building from  source $SOURCE js folder")

$SOURCEJS = $SOURCE + '\js'
$TARGETJS = $TARGET + '\js'

# CREATE target js folder if it doesn't already exist
If(!(test-path -PathType container $TARGETJS))
{
      echo ('CREATING target js folder ' + $TARGETJS)
      New-Item -ItemType Directory -Path $TARGETJS
}

# COPY js files
attrib -R $TARGETJS\*.js
copy-item -Path $SOURCEJS\*.js -Destination $TARGETJS
attrib +R $TARGETJS\*.js
