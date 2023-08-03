# run this from the xml folder which has the meta model src files:
# See  readme.md for an explanation of the source files.

# run this from the folder which has the src xml file

Param(
   [Parameter(Position=0,Mandatory=$True)]
       [string]$filenameOrFilenamePrefix,
   [Parameter(Mandatory=$False)]
       [switch]$logical,  
   [Parameter(Mandatory='')]
        [ValidateSet('', 'r','h','hs')]
        [System.String]$physicalType,  
   [Parameter(Mandatory='_')]
        [System.String]$longSeparator,  
   [Parameter(Mandatory='_')]
        [System.String]$shortSeparator, 
   [Parameter(Mandatory=$False)]
       [switch]$xpath,
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

if ($filenameOrFilenamePrefix.EndsWith(".xml"))
{
    $filenamePrefix = $filenameOrFilenamePrefix.substring(0,$filenameOrFilenamePrefix.Length-4)
}
else
{
    $filenamePrefix = $filenameOrFilenamePrefix
}

echo ('filenameOrFilenamePrefix ' + $filenameOrFilenamePrefix)
echo ('filenamePrefix ' + $filenamePrefix)


$diagramSource=        $filenamePrefix + '.xml'
$logicalSource=        $filenamePrefix + '.xml'
$physicalFilename=     $filenamePrefix + '..physical.xml'
$physicalDiagramSource=        $filenamePrefix + '..physical.xml'

echo ('diagram source is' + $diagramSource)

#  LOGICAL DIAGRAMS AND REPORTING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

$animateOption = if($animate){'-animate '}{''}
$debugswitchOption = if($debugswitch){'-debugswitch'}{''}

powershell -Command ("$ERHOME\scripts\genSVG.ps1  $diagramSource" + ' -outputFolder ..\docs ' + "$animateOption" + $debugswitchOption)

java -jar $SAXON_JAR -s:$diagramSource -xsl:$ERHOME\xslt\ERmodel2.html.xslt -o:..\docs\$filenamePrefix..report.html

if ($physicalType -ne '')
{
    #  LOGICAL 2 PHYSICAL %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    java -jar $SAXON_JAR -s:$logicalSource -xsl:$ERHOME\xslt\ERmodel2.physical.xslt -o:$physicalFilename style=$physicalType longSeparator=$longSeparator shortSeparator=$shortSeparator xpath=$(If ($xpath){'y'}Else{'n'}) debug=$(If ($debugswitch){'y'}Else{'n'})

    #  PHYSICAL DIAGRAMS AND REPORTING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    powershell -Command ("$ERHOME\scripts\genSVG.ps1  $physicalDiagramSource" + ' -outputFolder ..\docs ' + "$animateOption")


    java -jar $SAXON_JAR -s:$physicalDiagramSource -xsl:$ERHOME\xslt\ERmodel2.html.xslt -o:..\docs\$filenamePrefix..physical.report.html

    #  generation of xml schema

    java -jar $SAXON_JAR -s:$physicalFilename -xsl:$ERHOME\xslt\ERmodel2.rng.xslt -o:$ERHOME\schemas\$filenamePrefix.rng


    #  generate xslt's

    java -jar $SAXON_JAR -s:$physicalFilename -xsl:$ERHOME\xslt\ERmodel2.elaboration_xslt.xslt -o:$ERHOME\xslt\$filenamePrefix.elaboration.xslt

    java -jar $SAXON_JAR -s:$physicalFilename -xsl:$ERHOME\xslt\ERmodel2.referential_integrity_xslt.xslt -o:$ERHOME\xslt\$filenamePrefix.referential_integrity.xslt
}