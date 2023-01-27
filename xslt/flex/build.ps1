$commandFolder=Split-Path $MyInvocation.MyCommand.Path

. ($commandFolder + '\..\..\buildscripts\setBuildtimePathVariables.ps1')

echo ("*** building from  $SOURCE xslt flex folder")

$SOURCEXSLT = $SOURCE + '\xslt\flex'
$TARGETXSLT = $TARGET + '\xslt\flex'

# CREATE target xslt\flex folder if it doesn't already exist
If(!(test-path -PathType container $TARGETXSLT))
{
      echo ('CREATING target flex folder ' + $TARGETXSLT)
      New-Item -ItemType Directory -Path $TARGETXSLT
}

# COPY xslt files
attrib -R $TARGETXSLT\*.xslt
copy-item -Path $SOURCEXSLT\*.xslt -Destination $TARGETXSLT
attrib +R $TARGETXSLT\*.xslt
