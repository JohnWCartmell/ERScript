# run this from the folder which has the src xml file
#
# er2svg.ps1 <filebasename>.xml  
#
# produces an intermediate file  <filebasename>.flex.xml
# a schema check file TBD
# and an files
#               ../docs/<flenamebase..htnl
#               ../docs/<flenamebase..svg

Param(
   [Parameter(Position=0,Mandatory=$True)]
       [string]$pathToSourceXMLfile,
   [Parameter(Mandatory=$False)]
       [string]$outputFolder=$((Get-Item $pathToSourceXMLfile).DirectoryName + '/../docs'),
   [Parameter(Mandatory=$False)]
       [switch]$bundle,
   [Parameter(Mandatory=$False)]
       [switch]$animate,
   [Parameter(Mandatory=$False)]
       [switch]$debugswitch
)

#######################
 # most of the above parameters not yet implemented !!!!!!!!!!!
 #####################

$commandFolder=Split-Path $MyInvocation.MyCommand.Path

echo ('pathtosourcefile:' + $pathToSourceXMLfile)

$filenamebase=(Get-Item $pathToSourceXMLfile).Basename
$filenameExtension=(Get-Item $pathToSourceXMLfile).Extension
$filename=(Get-Item $pathToSourceXMLfile).Name
$srcDirectoryName = (Get-Item $pathToSourceXMLfile).DirectoryName

$tempFolder = ($srcDirectoryName + '/../temp')

echo ('er2svg.ps1 tempFolder: ' + $tempFolder) 
echo ('er2svg.ps1 outputFolder: ' + $outputFolder)
If(!(test-path -PathType container $tempFolder))
{
      New-Item -ItemType Directory -Path $tempFolder
}
If(!(test-path -PathType container $outputFolder))
{
      New-Item -ItemType Directory -Path $outputFolder
}

echo "er2svg.ps1 BEFORE set_path_variables.ps1 we have SAXON_PATH $SAXON_PATH"
. ($commandFolder +'/../../scripts/set_path_variables.ps1')
echo "er2svg.ps1 AFTER SAXON_PATH set_path_variables.ps1  $SAXON_PATH"

java -cp $SAXON_JAR net.sf.saxon.Transform -s:$pathToSourceXMLfile `
                      -xsl:$ERHOME/xslt/flex/ERmodel2.flex.xslt `
                       -o:$tempFolder/$filenamebase.flex.xml `
                       ERHOME=$ERHOME `
                       debug=$(If ($debugswitch){'y'}Else{'n'}) 

java -cp $SAXON_JAR net.sf.saxon.Transform -s:$tempFolder/$filenamebase.flex.xml `
                      -xsl:$ERHOME/flexDiagramming/xslt/diagram2.svg.xslt `
                       -warnings:silent `
                       -o:$outputFolder/$filenamebase.svg `
                       filestem=$filenamebase `
                       bundle=$(If ($bundle){'y'}Else{'n'}) `
                       animate=$(If ($animate){'y'}Else{'n'}) `
                       debug=$(If ($debugswitch){'y'}Else{'n'}) 


