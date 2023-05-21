# run this from the xml folder which has the meta model src files:
# See  readme.md for an explanation of the source files.

# run this from the folder which has the src xml file

Param(
   [Parameter(Position=0,Mandatory=$True)]
       [string]$filenamePrefix,
   [Parameter(Mandatory='')]
        [ValidateSet('r','h','hs')]
        [System.String]$physicalType, 
   [Parameter(Mandatory=$False)]
       [switch]$debugswitch,
   [Parameter(Mandatory=$False)]
       [switch]$trace
 )

$commandFolder=Split-Path $MyInvocation.MyCommand.Path

echo ('outputFolder ' + $outputFolder)

. ($commandFolder +'\set_path_variables.ps1')

$logicalSource=        $filenamePrefix + '..logical.xml'
$physicalFilename=     $filenamePrefix + '..physical.xml'

$debugswitchOption = if($debugswitch){'-debugswitch'}{''}

java -jar $SAXON_JAR -s:$logicalSource -xsl:$ERHOME\xslt\ERmodel2.physical.xslt -o:$physicalFilename style=$physicalType debug=$(If ($debugswitch){'y'}Else{'n'})
