echo ("*** building from  source $SOURCE xslt folder")

$SOURCEXSLT = $SOURCE + '\xslt'
$TARGETXSLT = $TARGET + '\xslt'

# CREATE target xslt folder if it doesn't already exist
If(!(test-path -PathType container $TARGETXSLT))
{
      echo ('CREATING target xslt folder ' + $TARGETXSLT)
      New-Item -ItemType Directory -Path $TARGETXSLT
}

# COPY xslt files
attrib -R $TARGETXSLT\*.xslt
copy-item -Path $SOURCEXSLT\*.xslt -Destination $TARGETXSLT
attrib +R $TARGETXSLT\*.xslt
