# run this from the xml folder which has the meta model src files:
# See  readme.md for an explanation of the source files.

# run this from the folder which has the src xml file

Param(
   [Parameter(Position=0,Mandatory=$True)]
       [string]$filenamePrefix,
   [Parameter(Mandatory=$False)]
       [switch]$logical,  
   [Parameter(Mandatory='')]
        [ValidateSet('', 'r','h','hs')]
        [System.String]$physicalType, 
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

echo ('outputFolder ' + $outputFolder)

. ($commandFolder +'\set_path_variables.ps1')


$diagramSource=        $filenamePrefix + '..diagram.xml'
# $reportOutputFilepath= '..\docs\' + $filenamePrefix + '..MYreport.html'
$logicalSource=        $filenamePrefix + '..logical.xml'
$physicalFilename=     $filenamePrefix + '..physical.xml'
$physicalDiagramSource=        $filenamePrefix + '..physical..diagram.xml'

echo ('diagram source is' + $diagramSource)

#  LOGICAL DIAGRAMS AND REPORTING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

$animateOption = if($animate){'-animate '}{''}

powershell -Command ("$ERHOME\scripts\genSVG.ps1  $diagramSource" + ' -outputFolder ..\docs ' + "$animateOption")

java -jar $SAXON_JAR -s:$diagramSource -xsl:$ERHOME\xslt\ERmodel2.html.xslt -o:..\docs\$filenamePrefix..report.html

if ($physicalType -ne '')
{
    #  LOGICAL 2 PHYSICAL %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    java -jar $SAXON_JAR -s:$logicalSource -xsl:$ERHOME\xslt\ERmodel2.physical.xslt -o:$physicalFilename style=$physicalType debug=$(If ($debugswitch){'y'}Else{'n'})

    #  PHYSICAL DIAGRAMS AND REPORTING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    powershell -Command ("$ERHOME\scripts\genSVG.ps1  $physicalDiagramSource" + ' -outputFolder ..\docs ' + "$animateOption")


    java -jar $SAXON_JAR -s:$physicalDiagramSource -xsl:$ERHOME\xslt\ERmodel2.html.xslt -o:..\docs\$filenamePrefix..physical.report.html

    #  generation of xml schema

    java -jar $SAXON_JAR -s:$physicalFilename -xsl:$ERHOME\xslt\ERmodel2.rng.xslt -o:$ERHOME\schemas\$filenamePrefix.rng


    #  generate xslt's

    java -jar $SAXON_JAR -s:$physicalFilename -xsl:$ERHOME\xslt\ERmodel2.elaboration_xslt.xslt -o:$ERHOME\xslt\$filenamePrefix.elaboration.xslt

    java -jar $SAXON_JAR -s:$physicalFilename -xsl:$ERHOME\xslt\ERmodel2.referential_integrity_xslt.xslt -o:$ERHOME\xslt\$filenamePrefix.referential_integrity.xslt
}