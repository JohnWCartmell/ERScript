# run this from the folder which has the src xml file

Param(
   [Parameter(Position=0,Mandatory=$True)]
       [string]$pathToSourceXMLfile,
   [Parameter(Mandatory=$False)]
       [string]$outputFolder={(Get-Item $pathToSourceXMLfile).DirectoryName + '\..\docs'},
   [Parameter(Mandatory=$False)]
       [switch]$bundle,
   [Parameter(Mandatory=$False)]
       [switch]$animate,
   [Parameter(Mandatory=$False)]
       [switch]$debugswitch,
   [Parameter(Mandatory=$False)]
       [switch]$trace,
   [Parameter(Mandatory=$False)]
       [switch]$scopes,
   [Parameter(Mandatory=$False)]
       [switch]$relids
)



$commandFolder=Split-Path $MyInvocation.MyCommand.Path

echo $commandFolder

echo ('pathtosourcefile' + $pathToSourceXMLfile)

$filenamebase=(Get-Item $pathToSourceXMLfile).Basename
$filenameExtension=(Get-Item $pathToSourceXMLfile).Extension
$filename=(Get-Item $pathToSourceXMLfile).Name
$srcDirectoryName = (Get-Item $pathToSourceXMLfile).DirectoryName

#$outputFolder = $srcDirectoryName + '\..\docs'
If(!(test-path -PathType container $outputFolder))
{
      New-Item -ItemType Directory -Path $outputFolder
}


. ($commandFolder +'\set_path_variables.ps1')

echo $SAXON_JAR

java -jar $SAXON_JAR -s:$pathToSourceXMLfile `
                      -xsl:$ERHOME\xslt\ERmodel2.svg.xslt `
                       -o:..\docs\$filenamebase.svg `
                       filestem=$filenamebase `
                       bundle=$(If ($bundle){'y'}Else{'n'}) `
                       animate=$(If ($animate){'y'}Else{'n'}) `
                       debug=$(If ($debugswitch){'y'}Else{'n'}) `
                       trace=$(If ($trace){'y'}Else{'n'}) `
                       scopes=$(If ($scope){'y'}Else{'n'}) `
                       relids=$(If ($relids){'y'}Else{'n'})
