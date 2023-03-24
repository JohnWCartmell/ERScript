# run this from the folder which has the src xml file

Param(
   [Parameter(Position=0,Mandatory=$True)]
       [string]$filenamePrefix,
   [Parameter(Mandatory=$False)]
       [string]$outputFolder=$((Get-Item $pathToSourceXMLfile).DirectoryName)
)


$commandFolder=Split-Path $MyInvocation.MyCommand.Path

$logicalSource=        $filenamePrefix + '..logical.xml'
$physicalFilename=     $filenamePrefix + '..physical.xml'
$rngFilename=     $filenamePrefix + '..physical.rng'

echo ("outputFolder:'" + $outputFolder +"'")
If(!(test-path -PathType container $outputFolder))
{
      New-Item -ItemType Directory -Path $outputFolder
}

. ($commandFolder +'\set_path_variables.ps1')

echo ('SAXON_JAR' + $SAXON_JAR)
java -jar $SAXON_JAR -s:$logicalSource `
                       -xsl:$TARGET\xslt\ERmodel2.physical.xslt `
                       -o:$outputFolder\$physicalFilename `
                       style='hs' 

java -jar $SAXON_JAR -opt:0 -s:$outputFolder\$physicalFilename `
                      -xsl:$ERHOME\xslt\ERmodel2.rng.xslt `
                       -o:$outputFolder\$rngFilename
