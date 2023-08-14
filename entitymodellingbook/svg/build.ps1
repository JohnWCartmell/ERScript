. ..\..\buildscripts\setBuildtimePathVariables.ps1

echo ("*** building from  $SOURCE entity modelling book svg folder")

$SOURCESVG = $SOURCE + '\entitymodellingbook\svg'
$TARGETWWW = $TARGET + '\www.entitymodelling.org'
$TARGETSVG = $TARGETWWW + '\svg'

# CREATE target svg folder if it doesn't already exist
If(!(test-path -PathType container $TARGETSVG))
{
      echo ('CREATING target folder ' + $TARGETSVG)
      New-Item -ItemType Directory -Path $TARGETSVG
}


# COPY svg files
attrib -R $TARGETSVG\*.svg
copy-item -Path $SOURCESVG\*.svg -Destination $TARGETSVG
attrib +R $TARGETSVG\*.svg



