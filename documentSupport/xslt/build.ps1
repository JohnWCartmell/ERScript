$commandFolder=Split-Path $MyInvocation.MyCommand.Path

. ($commandFolder + '\..\..\buildscripts\setBuildtimePathVariables.ps1')

echo ("*** building from   $SOURCE xslt folder")


$SOURCESCRIPTS = $SOURCE + '\documentSupport\xslt'
$TARGETSCRIPTS = $TARGET + '\documentSupport\xslt' 

# CREATE target scripts folder if it doesn't already exist
If(!(test-path -PathType container $TARGETSCRIPTS))
{
      echo ('CREATING target scripts folder ' + $TARGETSCRIPTS)
      New-Item -ItemType Directory -Path $TARGETSCRIPTS
}

# COPY xslt scripts 
attrib -R $TARGETSCRIPTS\*.xslt
copy-item -Path $SOURCESCRIPTS\*.xslt -Destination $TARGETSCRIPTS
attrib +R $TARGETSCRIPTS\*.xslt

