
Param(
   [Parameter(Mandatory=$False)]
       [string]$filename
)

$commandFolder=Split-Path $MyInvocation.MyCommand.Path

. ($commandFolder + '\..\..\buildscripts\setBuildtimePathVariables.ps1')

$EXAMPLEFOLDERNAME='examplesSelected\theDramaticArts'

$SOURCEXML = $SOURCE  +  '\' + $EXAMPLEFOLDERNAME
$TARGETXML = $TARGET + '\' + $EXAMPLEFOLDERNAME +'\xml'
$TARGETWWW = $TARGET + '\www.entitymodelling.org'
$TARGETSVGFOLDER = $TARGETWWW + '\svg'
# $TARGETDOCS = $TARGET + '\' + $EXAMPLEFOLDERNAME + '\docs'
$TARGETTEXFOLDER = $TARGET + '\docs\images'


#was here

if ($PSBoundParameters.ContainsKey('filename') -and ($filename -notmatch '\.\.diagram\.xml$')) {
    throw "Error: Filename must end with '..diagram.xml'. Given: $filename"
}


# CREATE target xml folder if it doesn't already exist
If(!(test-path -PathType container $TARGETXML))
{
      echo ('CREATING target folder ' + $TARGETXML)
      New-Item -ItemType Directory -Path $TARGETXML
}

# CREATE target docs folder if it doesn't already exist
#If(!(test-path -PathType container $TARGETDOCS))
#{
 #     echo ('CREATING target folder ' + $TARGETDOCS)
 #     New-Item -ItemType Directory -Path $TARGETDOCS
#}

# COPY files
attrib -R $TARGETXML\*.xml
#copy all xml files # bit ugly but I don't know which ones needed
copy-item -Path $SOURCEXML\*.xml -Destination $TARGETXML


# This function called from temp build folder 
function Build-File {
    param (
        $FileName
    )
    $diagramName = $Filename -replace '\.\.diagram\.xml$', ''
   Write-Output $prefix
    echo('Building ' +  $diagramName)
   . $TARGET\scripts\buildExampleSVG.ps1 $diagramName     `
                             -svgOutputFolder $TARGETSVGFOLDER `
                             -texOutputFolder $TARGETTEXFOLDER `
                             -animate -shortSeparator NA -longSeparator NA
}


pushd $TARGETXML
echo ('*********** location: ' + (Get-Location) )

if ($false)   ## CONDITIONED OUT IN TESTING OF FLEX
{

if ($PSBoundParameters.ContainsKey('filename')){

    $file=Get-Item $filename
    echo ('basename is:' + $file.Basename) 
    echo ('extension is:' + $file.Extension)

    echo ('need build from' + $filename)
    Build-File -FileName $filename
}else{
    echo 'building all ..diagram files'
    get-ChildItem -Path *..diagram.xml  | Foreach-Object {
      echo 'building ' + $_.Name
      Build-File -FileName $_.Name
    }
    echo 'done building all'
}

} #END OUT CONDITIONING

#if ($false)
#{
echo 'theDramaticArts Flex version'
. $TARGET\flexDiagramming\scripts\er2flex2svg.ps1 dramaticArts1..logical.xml -animate  -debugSwitch
#}

popd 


