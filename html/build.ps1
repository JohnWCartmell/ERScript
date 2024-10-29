$commandFolder=Split-Path $MyInvocation.MyCommand.Path

. ($commandFolder + '\..\buildscripts\setBuildtimePathVariables.ps1')

echo ("*** building from  $SOURCE html folder")

attrib -R $TARGET\index.html
copy-item $SOURCE\html\index.html -Destination $TARGET
attrib +R $TARGET\index.html

$TARGETHTML = $TARGET + '\html'
# CREATE target html folder if it doesn't already exist
If(!(test-path -PathType container $TARGETHTML))
{
      echo ('CREATING target css folder ' + $TARGETHTML)
      New-Item -ItemType Directory -Path $TARGETHTML
}

attrib -R $TARGET\*.md
copy-item $SOURCE\html\*.md -Destination $TARGETHTML
attrib +R $TARGET\*.md

attrib -R $TARGET\*.html
copy-item $SOURCE\html\*.html -Destination $TARGETHTML
attrib +R $TARGET\*.html

. 2023/build.ps1

