. ..\buildscripts\setBuildtimePathVariables.ps1

echo ("*** building from  $SOURCE xslt folder")

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

echo "."
echo "================================================================= begin flex ==================="
echo "***"
& $SOURCEXSLT\flex\build.ps1                
echo "***"
echo "================================================================= end flex ====================="
echo "."

echo "."
echo "================================================================= begin EBNF ==================="
echo "***"
& $SOURCEXSLT\EBNF\build.ps1                
echo "***"
echo "================================================================= end EBNF ====================="
echo "."
