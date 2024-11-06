# run this from the folder which has the src xml file
#
#flex2svg.ps1 <filebasename>.xml  
#
# produces files
#               ../docs/<flenamebase..flex.html
#               ../docs/<flenamebase..flex.svg

Param(
   [Parameter(Position=0,Mandatory=$True)]
       [string]$pathToSourceXMLfile,
   [Parameter(Mandatory=$False)]
       [string]$outputFolder=$((Get-Item $pathToSourceXMLfile).DirectoryName + '\docs'),
   [Parameter(Mandatory=$False)]
       [switch]$bundle,
   [Parameter(Mandatory=$False)]
       [switch]$animate,
   [Parameter(Mandatory=$False)]
       [switch]$debugswitch
)


$commandFolder=Split-Path $MyInvocation.MyCommand.Path

echo ('pathtosourcefile' + $pathToSourceXMLfile)

$filenamebase=(Get-Item $pathToSourceXMLfile).Basename
$filenameExtension=(Get-Item $pathToSourceXMLfile).Extension
$filename=(Get-Item $pathToSourceXMLfile).Name
$srcDirectoryName = (Get-Item $pathToSourceXMLfile).DirectoryName


If(!(test-path -PathType container $outputFolder))
{
      New-Item -ItemType Directory -Path $outputFolder
}


. ($commandFolder +'\..\..\scripts\set_path_variables.ps1')


java -jar $SAXON_JAR -s:$pathToSourceXMLfile `
                      -xsl:$ERHOME\flexDiagramming\xslt\diagram2.svg.xslt `
                       -o:$outputFolder\$filenamebase.svg `
                       -warnings:fatal `
                       filestem=$filenamebase `
                       bundle=$(If ($bundle){'y'}Else{'n'}) `
                       animate=$(If ($animate){'y'}Else{'n'}) `
                       debug=$(If ($debugswitch){'y'}Else{'n'}) 




 