echo ("*** building from  source $SOURCE css folder")

$SOURCECSS = $SOURCE + '\css'
$TARGETCSS = $TARGET + '\css'

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
