$commandFolder=Split-Path $MyInvocation.MyCommand.Path

. ($commandFolder + '\..\..\..\..\buildscripts\setBuildtimePathVariables.ps1')

echo ("*** building from  $SOURCE css folder")

$SOURCECSS = $SOURCE + '\flexDiagramming\methods\era\css'
$TARGETCSS = $TARGET + '\css'

echo ('SOURCECSS ' + $SOURCECSS)

# CREATE target css folder if it doesn't already exist
If(!(test-path -PathType container $TARGETCSS))
{
      echo ('CREATING target css folder ' + $TARGETCSS)
      New-Item -ItemType Directory -Path $TARGETCSS
}

# COPY css file
attrib -R $TARGETCSS\*.css
copy-item -Path $SOURCECSS\*.css -Destination $TARGETCSS
attrib +R $TARGETCSS\*.css
