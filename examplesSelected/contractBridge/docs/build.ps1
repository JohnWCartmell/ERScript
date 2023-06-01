$commandFolder=Split-Path $MyInvocation.MyCommand.Path

. ($commandFolder + '\..\..\..\buildscripts\setBuildtimePathVariables.ps1')

echo ("*** building from  $SOURCE css folder")

$SOURCEXML = $SOURCE + '\examplesSelected\contractBridge\docs'
$TARGETXML = $TARGET + '\examplesSelected\contractBridge\docs'


# CREATE target folder if it doesn't already exist
If(!(test-path -PathType container $TARGETXML))
{
      echo ('CREATING target folder ' + $TARGETXML)
      New-Item -ItemType Directory -Path $TARGETXML
}

# COPY xml files
attrib -R $TARGETXML\*.html
attrib -R $TARGETXML\*.js
attrib -R $TARGETXML\*.css
copy-item -Path $SOURCEXML\*.html -Destination $TARGETXML
copy-item -Path $SOURCEXML\*.js -Destination $TARGETXML
copy-item -Path $SOURCEXML\*.css -Destination $TARGETXML
attrib +R $TARGETXML\*.html
attrib +R $TARGETXML\*.js
attrib +R $TARGETXML\*.css


pushd $TARGETXML
echo 'Contract Bridge'


popd 



