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

# COPY xslt and xpath files
attrib -R $TARGETXSLT\*.xslt
copy-item -Path $SOURCEXSLT\*.xslt -Destination $TARGETXSLT
copy-item -Path $SOURCEXSLT\*.xpath -Destination $TARGETXSLT
attrib +R $TARGETXSLT\*.xslt

# COPY the meta model 
attrib -R $TARGETXSLT\ERA..physical.xml
copy-item -Path $SOURCEXSLT\ERA..physical.xml -Destination $TARGETXSLT
attrib +R $TARGETXSLT\ERA..physical.xml

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
