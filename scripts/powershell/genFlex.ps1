# run this from the folder which has the src xml file

Param(
   [Parameter(Position=0,Mandatory=$True)]
       [string]$pathToSourceXMLfile,
   [Parameter(Mandatory=$False)]
       [string]$outputFolder=$((Get-Item $pathToSourceXMLfile).DirectoryName),
   [Parameter(Mandatory=$False)]
       [switch]$debugswitch
)

$commandFolder=Split-Path $MyInvocation.MyCommand.Path

echo ('pathtosourcefile' + $pathToSourceXMLfile)

$filenamebase=(Get-Item $pathToSourceXMLfile).Basename
$filenameExtension=(Get-Item $pathToSourceXMLfile).Extension
$filename=(Get-Item $pathToSourceXMLfile).Name
$srcDirectoryName = (Get-Item $pathToSourceXMLfile).DirectoryName

echo ('outputFolder' + $outputFolder)
If(!(test-path -PathType container $outputFolder))
{
      New-Item -ItemType Directory -Path $outputFolder
}

. ($commandFolder +'\set_path_variables.ps1')


java -jar $SAXON_JAR -s:$pathToSourceXMLfile `
                      -xsl:$ERHOME\xslt\flex\ERmodel2.flex.xslt `
                       -o:$outputFolder\$filenamebase.flex.xml `
                        debug=$(If ($debugswitch){'y'}Else{'n'}) 
