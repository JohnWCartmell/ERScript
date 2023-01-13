$commandFolder=Split-Path $MyInvocation.MyCommand.Path

. ($commandFolder + '\..\buildscripts\setBuildtimePathVariables.ps1')

echo ("*** building from  $SOURCE html folder")

attrib -R $TARGET\index.html
copy-item $SOURCE\html\index.html -Destination $TARGET
attrib +R $TARGET\index.html
