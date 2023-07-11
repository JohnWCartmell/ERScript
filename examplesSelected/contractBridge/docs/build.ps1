$commandFolder=Split-Path $MyInvocation.MyCommand.Path

. ($commandFolder + '\..\..\..\buildscripts\setBuildtimePathVariables.ps1')

echo ("*** building from  $SOURCE docs folder")

$SOURCEDOCS = $SOURCE + '\examplesSelected\contractBridge\docs'
$TARGETDOCS = $TARGET + '\examplesSelected\contractBridge\docs'


# CREATE target folder if it doesn't already exist
If(!(test-path -PathType container $TARGETDOCS))
{
      echo ('CREATING target folder ' + $TARGETDOCS)
      New-Item -ItemType Directory -Path $TARGETDOCS
}

# COPY xml files
attrib -R $TARGETDOCS\*.html
attrib -R $TARGETDOCS\*.js
attrib -R $TARGETDOCS\*.css
copy-item -Path $SOURCEDOCS\*.html -Destination $TARGETDOCS
copy-item -Path $SOURCEDOCS\*.js -Destination $TARGETDOCS
copy-item -Path $SOURCEDOCS\*.css -Destination $TARGETDOCS
attrib +R $TARGETDOCS\*.html
attrib +R $TARGETDOCS\*.js
attrib +R $TARGETDOCS\*.css

############################################################################################
echo ("*** building from  $SOURCE XML  folder")

$SOURCEXML = $SOURCE + '\examplesSelected\contractBridge\xml'
$TARGETXML = $TARGET + '\examplesSelected\contractBridge\xml'

# CREATE target folder if it doesn't already exist
If(!(test-path -PathType container $TARGETXML))
{
      echo ('CREATING target folder ' + $TARGETXML)
      New-Item -ItemType Directory -Path $TARGETXML
}

# COPY xml files
attrib -R $TARGETXML\*.xml
copy-item -Path $SOURCEXML\*.xml -Destination $TARGETXML
attrib +R $TARGETXML\*.xml
attrib -R $TARGETXML\*..physical.xml    #these are generated and therefore need to be overwriteable

pushd $TARGETXML
echo 'Cricket Example'

echo 'Run surface ER.instanceValidation.xslt on logical model'
. $TARGET\scripts\ER.instanceValidation.ps1 thePack..logical.xml -outputFolder ..\docs

if ($false)
{
echo 'buildExampleSVG'
. $TARGET\scripts\buildExampleSVG.ps1 thePack -animate -physicalType hs -shortSeparator NA -longSeparator NA -debugSwitch

echo 'Run ER.instanceValidation.xslt on physical model'
. $TARGET\scripts\ER.instanceValidation.ps1 thePack..physical.xml -outputFolder ..\docs -debugSwitch

echo 'Run ER.instanceValidation.xslt on valid instance'
. $TARGET\scripts\ER.instanceValidation.ps1 packInstance.xml -outputFolder ..\docs
}

echo 'thePack Flex version'
. $TARGET\flexDiagramming\scripts\er2flex2svg.ps1 thePack..logical.xml -animate 


popd 



