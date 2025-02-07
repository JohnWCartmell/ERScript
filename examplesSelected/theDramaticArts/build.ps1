$commandFolder=Split-Path $MyInvocation.MyCommand.Path

. ($commandFolder + '\..\..\buildscripts\setBuildtimePathVariables.ps1')

echo ("*** building from  $SOURCE theDramaticArts folder")

$SOURCEXML = $SOURCE + '\examplesSelected\theDramaticArts'
$TARGETXML = $TARGET + '\examplesSelected\theDramaticArts\xml'
$TARGETSVGFOLDER = $TARGET + '\www.entitymodelling.org\svg'
$TARGETTEXFOLDER = $TARGET + '\docs\images'

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

if ($false)
{
echo 'theDramaticArts Example'
. $TARGET\scripts\buildExampleSVG.ps1 dramaticArts1       `
                             -svgOutputFolder $TARGETSVGFOLDER `
                             -texOutputFolder $TARGETTEXFOLDER `
                             -animate -shortSeparator NA -longSeparator NA

echo 'theDramaticArts Annotated '
. $TARGET\scripts\buildExampleSVG.ps1 dramaticArts1.annotate       `
                             -svgOutputFolder $TARGETSVGFOLDER `
                             -texOutputFolder $TARGETTEXFOLDER `
                             -animate -shortSeparator NA -longSeparator NA

echo 'theDramaticArts Play Playwright Relationship'
. $TARGET\scripts\buildExampleSVG.ps1 dramaticArtsPlayPlaywright    `
                             -svgOutputFolder $TARGETSVGFOLDER `
                             -texOutputFolder $TARGETTEXFOLDER `
                             -animate -shortSeparator NA -longSeparator NA

echo 'theDramaticArts Character Fragment'
. $TARGET\scripts\buildExampleSVG.ps1 dramaticArtsCharacterFragment       `
                             -svgOutputFolder $TARGETSVGFOLDER `
                             -texOutputFolder $TARGETTEXFOLDER `
                             -animate -shortSeparator NA -longSeparator NA

echo 'theDramaticArts Dramatic Role Fragment'
. $TARGET\scripts\buildExampleSVG.ps1 dramaticArtsDramaticRoleFragment       `
                             -svgOutputFolder $TARGETSVGFOLDER `
                             -texOutputFolder $TARGETTEXFOLDER `
                             -animate -shortSeparator NA -longSeparator NA

echo 'theDramaticArts Production Fragment'
. $TARGET\scripts\buildExampleSVG.ps1 dramaticArtsProductionFragment      `
                             -svgOutputFolder $TARGETSVGFOLDER `
                             -texOutputFolder $TARGETTEXFOLDER `
                             -animate -shortSeparator NA -longSeparator NA      

echo 'theDramaticArts dramaticArtsPortrayalScopeFragment'
. $TARGET\scripts\buildExampleSVG.ps1 dramaticArtsPortrayalScopeFragment     `
                             -svgOutputFolder $TARGETSVGFOLDER `
                             -texOutputFolder $TARGETTEXFOLDER `
                             -animate -shortSeparator NA -longSeparator NA    
                  
echo 'theDramaticArts dramaticArtsPortrayalScope'
. $TARGET\scripts\buildExampleSVG.ps1 dramaticArtsPortrayalScope     `
                             -svgOutputFolder $TARGETSVGFOLDER `
                             -texOutputFolder $TARGETTEXFOLDER `
                             -animate -shortSeparator NA -longSeparator NA   

echo 'theDramaticArts dramaticArtsPath1'
. $TARGET\scripts\buildExampleSVG.ps1 dramaticArtsPath1     `
                             -svgOutputFolder $TARGETSVGFOLDER `
                             -texOutputFolder $TARGETTEXFOLDER `
                             -animate -shortSeparator NA -longSeparator NA 
   
echo 'theDramaticArts dramaticArtsPath2'
. $TARGET\scripts\buildExampleSVG.ps1 dramaticArtsPath2     `
                             -svgOutputFolder $TARGETSVGFOLDER `
                             -texOutputFolder $TARGETTEXFOLDER `
                             -animate -shortSeparator NA -longSeparator NA 

echo 'theDramaticArts Character..identificationScheme'
. $TARGET\scripts\buildExampleSVG.ps1 dramaticArtsCharacter..identificationScheme    `
                             -svgOutputFolder $TARGETSVGFOLDER `
                             -texOutputFolder $TARGETTEXFOLDER `
                             -animate -shortSeparator NA -longSeparator NA   


echo 'theDramaticArts Character..linearIdentificationScheme'
. $TARGET\scripts\buildExampleSVG.ps1 dramaticArtsCharacter..linearIdentificationScheme    `
                             -svgOutputFolder $TARGETSVGFOLDER `
                             -texOutputFolder $TARGETTEXFOLDER `
                             -animate -shortSeparator NA -longSeparator NA

echo 'theDramaticArts production..identificationScheme'
. $TARGET\scripts\buildExampleSVG.ps1 dramaticArtsProduction..identificationScheme    `
                             -svgOutputFolder $TARGETSVGFOLDER `
                             -texOutputFolder $TARGETTEXFOLDER `
                             -animate -shortSeparator NA -longSeparator NA 
   

echo 'theDramaticArts production..linearIdentificationScheme'
. $TARGET\scripts\buildExampleSVG.ps1 dramaticArtsProduction..linearIdentificationScheme    `
                             -svgOutputFolder $TARGETSVGFOLDER `
                             -texOutputFolder $TARGETTEXFOLDER `
                             -animate -shortSeparator NA -longSeparator NA 
                             
echo 'theDramaticArts role..identificationScheme'
. $TARGET\scripts\buildExampleSVG.ps1 dramaticArtsRole..identificationScheme    `
                             -svgOutputFolder $TARGETSVGFOLDER `
                             -texOutputFolder $TARGETTEXFOLDER `
                             -animate -shortSeparator NA -longSeparator NA  
}

echo 'theDramaticArts role..linearIdentificationScheme'
. $TARGET\scripts\buildExampleSVG.ps1 dramaticArtsRole..linearIdentificationScheme    `
                             -svgOutputFolder $TARGETSVGFOLDER `
                             -texOutputFolder $TARGETTEXFOLDER `
                             -animate -shortSeparator NA -longSeparator NA 

if ($false)
{
echo 'theDramaticArts Flex version'
. $TARGET\flexDiagramming\scripts\er2flex2svg.ps1 dramaticArts1..logical.xml -animate
}

popd 



