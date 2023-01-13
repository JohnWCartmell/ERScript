




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
                      -xsl:$ERHOME\xslt\ERmodel2.svg.xslt `
                       -o:$outputFolder\$filenamebase.svg `
                       filestem=$filenamebase `
                       bundle=$(If ($bundle){'y'}Else{'n'}) `
                       animate=$(If ($animate){'y'}Else{'n'}) `
                       debug=$(If ($debugswitch){'y'}Else{'n'}) `
                       trace=$(If ($trace){'y'}Else{'n'}) `
                       scopes=$(If ($scope){'y'}Else{'n'}) `
                       relids=$(If ($relids){'y'}Else{'n'})
