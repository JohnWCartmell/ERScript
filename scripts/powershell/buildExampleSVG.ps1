# run this from the xml folder which has the meta model src files:
# See  readme.md for an explanation of the source files.

# run this from the folder which has the src xml file

# 01/10/2024 Complete the implementation of the flags $xpath, $bundle, $trace, $scopes, $relids

Param(
   [Parameter(Position=0,Mandatory=$True)]
       [string]$filenameOrFilenamePrefix,
   [Parameter(Mandatory=$False)]
       [System.String]$svgOutputFolder = '..\docs',
   [Parameter(Mandatory=$False)]
       [string]$texOutputFolder = '',
   [Parameter(Mandatory=$False)] 
       [switch]$logical,  
   [Parameter(Mandatory='')]
        [ValidateSet('', 'r','h','hs')]
        [System.String]$physicalType,  
   [Parameter(Mandatory=$False)]
        [System.String]$longSeparator = '_',  
   [Parameter(Mandatory=$False)]
        [System.String]$shortSeparator = '_', 
   [Parameter(Mandatory=$False)]
       [switch]$xpath,
   [Parameter(Mandatory='')]
       [System.String]$elaboration_xslt_folder_path,
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


. ($commandFolder +'\set_path_variables.ps1')

if ($filenameOrFilenamePrefix.EndsWith(".xml"))
{
    $filenamePrefix = $filenameOrFilenamePrefix.substring(0,$filenameOrFilenamePrefix.Length-4)
}
else
{
    $filenamePrefix = $filenameOrFilenamePrefix
}

echo ('buildExampleSVG.ps1: filenameOrFilenamePrefix is ' + $filenameOrFilenamePrefix)
echo ('buildExampleSVG.ps1: filenamePrefix is ' + $filenamePrefix)
echo ('buildExampleSVG.ps1: svgOutputFolder is' + $svgOutputFolder)

$diagramSource=        $filenamePrefix + '..diagram.xml'
# $reportOutputFilepath= '..\docs\' + $filenamePrefix + '..MYreport.html'
$logicalSource=        $filenamePrefix + '..logical.xml'
$physicalFilename=     $filenamePrefix + '..physical.xml'
$physicalDiagramSource=        $filenamePrefix + '..physical..diagram.xml'

echo ('buildExampleSVG.ps1: diagram source is' + $diagramSource)

#  LOGICAL DIAGRAMS AND REPORTING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

$texOutputFolderOption = if($TEXOUTPUTFOLDER -ne ''){' -texOutputFolder '}{''}
$xpathOption = if($xpath){' -xpath '}{''}
$bundleOption = if($bundle){' -bundle '}{''}
$animateOption = if($animate){' -animate '}{''}
$debugswitchOption = if($debugswitch){' -debugswitch'}{''}
$traceOption = if($trace){' -trace '}{''}
$scopesOption = if($scopes){' -scope '}{''}
$relidsOption = if($relids){' -relids '}{''}

powershell -Command ("$ERHOME\scripts\genSVG.ps1  $diagramSource" `
               + ' -outputFolder ' + $svgOutputFolder `
               + "$texOutputFolderOption" + $texOutputFolder `
               + $xpathOption                         `
               + $bundleOption                        `
               + $animateOption                     `
               + $debugswitchOption                  `
               + $traceOption                         `
               + $scopesOption                        `
               + $relidsOption)                         

java -jar $SAXON_JAR -s:$diagramSource -xsl:$ERHOME\xslt\ERmodel2.html.xslt -o:..\docs\$filenamePrefix..report.html

if ($physicalType -ne '')
{
    #  LOGICAL 2 PHYSICAL %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    java -jar $SAXON_JAR -s:$logicalSource -xsl:$ERHOME\xslt\ERmodel2.physical.xslt -o:$physicalFilename style=$physicalType longSeparator=$longSeparator shortSeparator=$shortSeparator xpath=$(If ($xpath){'y'}Else{'n'}) debug=$(If ($debugswitch){'y'}Else{'n'})

    #  PHYSICAL DIAGRAMS AND REPORTING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    powershell -Command ("$ERHOME\scripts\genSVG.ps1  $physicalDiagramSource" `
               + ' -outputFolder ' + $svgOutputFolder   `
               + "$texOutputFolderOption" + $texOutputFolder `
               + "$animateOption"                     `
               + $debugswitchOption)


    java -jar $SAXON_JAR -s:$physicalDiagramSource -xsl:$ERHOME\xslt\ERmodel2.html.xslt -o:..\docs\$filenamePrefix..physical.report.html

    #  generation of xml schema
    echo 'buildExampleSVG.ps1: generate .rng' 
    java -jar $SAXON_JAR -s:$physicalFilename -xsl:$ERHOME\xslt\ERmodel2.rng.xslt -o:$ERHOME\schemas\$filenamePrefix.rng

    if ($elaboration_xslt_folder_path -ne "")
    {
    echo 'buildExampleSVG.ps1: generate elaboration xslt' 
    #  generate xslt
    java -jar $SAXON_JAR -s:$physicalFilename -xsl:$ERHOME\xslt\ERmodel2.elaboration_xslt.xslt -o:$elaboration_xslt_folder_path\$filenamePrefix.elaboration.xslt
    }

}