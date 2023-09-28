. ..\..\buildscripts\setBuildtimePathVariables.ps1

echo ("*** building from  $SOURCE entity modelling book handedited_svg_and_tex folder")

$SOURCEFOLDER = $SOURCE + '\entitymodellingbook\handedited_svg_and_tex'
$TARGETWWW = $TARGET + '\www.entitymodelling.org'
$TARGETSVG = $TARGETWWW + '\svg'
$TARGETTEX = $TARGET + '\docs\images'

# CREATE target svg folder if it doesn't already exist
If(!(test-path -PathType container $TARGETSVG))
{
      echo ('CREATING target folder ' + $TARGETSVG)
      New-Item -ItemType Directory -Path $TARGETSVG
}

# COPY svg files
attrib -R $TARGETSVG\*.svg
copy-item -Path $SOURCEFOLDER\*.svg -Destination $TARGETSVG
attrib +R $TARGETSVG\*.svg

# COPY tex files
attrib -R $TARGETTEX\*.tex
copy-item -Path $SOURCEFOLDER\*.tex -Destination $TARGETTEX
attrib +R $TARGETTEX\*.tex



