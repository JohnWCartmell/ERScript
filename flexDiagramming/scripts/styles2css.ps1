# run this from the folder which has the src xml file
#
#flex2svg.ps1 <filebasename>.xml  
#
# produces files
#               ../docs/<filenamebase>.css

Param(
   [Parameter(Position=0,Mandatory=$True)]
       [string]$pathToSourceXMLfile,
   [Parameter(Mandatory=$False)]
       [string]$outputFolder=$((Get-Item $pathToSourceXMLfile).DirectoryName + '\..\css')
)


$commandFolder=Split-Path $MyInvocation.MyCommand.Path

echo ('pathtosourcefile' + $pathToSourceXMLfile)

echo ('output folder' + $outputFolder)

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
                      -xsl:$ERHOME\flexDiagramming\xslt\styles2.css.xslt `
                       -o:$outputFolder\$filenamebase.css  



 