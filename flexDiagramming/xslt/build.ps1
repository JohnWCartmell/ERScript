
$commandFolder=Split-Path $MyInvocation.MyCommand.Path

. ($commandFolder +'\..\..\buildscripts\setBuildtimePathVariables.ps1')


echo ("*** building from  $SOURCE flexDiagramming xslt folder")

$SOURCEXSLT = $SOURCE + '\flexDiagramming\xslt'
$TARGETXSLT = $TARGET + '\flexDiagramming\xslt'

# CREATE target xslt folder if it doesn't already exist
If(!(test-path -PathType container $TARGETXSLT))
{
      echo ('CREATING target xslt folder ' + $TARGETXSLT)
      New-Item -ItemType Directory -Path $TARGETXSLT
}

# COPY xslt files
#####     attrib -R $TARGETXSLT\*.xslt
copy-item -Path $SOURCEXSLT\*.xslt -Destination $TARGETXSLT
#####     attrib +R $TARGETXSLT\*.xslt
