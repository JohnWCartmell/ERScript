# run this from the folder which has the src xml file

Param(
   [Parameter(Position=0,Mandatory=$True)]
       [string]$pathToSourceXMLfile,
   [Parameter(Mandatory=$False)]
       [string]$outputFolder=$((Get-Item $pathToSourceXMLfile).DirectoryName)
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

echo $SAXON_JAR

java -jar $SAXON_JAR -opt:0 -s:$pathToSourceXMLfile `
                      -xsl:$ERHOME\xslt\EBNF.parse.xslt `
                       -o:$outputFolder\$filenamebase.parseout.xml
