$commandFolder=Split-Path $MyInvocation.MyCommand.Path

. ($commandFolder + '\..\..\buildscripts\setBuildtimePathVariables.ps1')

echo ("*** building from  $SOURCE html/2023 folder")


$TARGETHTML = $TARGET + '\html\2023'
# CREATE target html folder if it doesn't already exist
If(!(test-path -PathType container $TARGETHTML))
{
      echo ('CREATING target css folder ' + $TARGETHTML)
      New-Item -ItemType Directory -Path $TARGETHTML
}

attrib -R $TARGET\*.md
copy-item $SOURCE\html\2023*.md -Destination $TARGETHTML
attrib +R $TARGET\*.md

attrib -R $TARGET\*.html
copy-item $SOURCE\html\2023\*.html -Destination $TARGETHTML
attrib +R $TARGET\*.html

