
$commandFolder=Split-Path $MyInvocation.MyCommand.Path

. ($commandFolder + '\..\buildscripts\setBuildtimePathVariables.ps1')

echo ("*** building from  $SOURCE EBNFGrammar folder")

$SOURCEFLEXDIAGRAMMING = $SOURCE + '\EBNFGrammar'


echo "."
echo "================================================================= begin mini-grammar ==================="
echo "***"
& $SOURCEFLEXDIAGRAMMING\mini-grammar\build.ps1  
echo "***"
echo "================================================================= end mini-grammar ====================="
echo "."

echo "."
echo "================================================================= begin xpath-3.1 ==================="
echo "***"
& $SOURCEFLEXDIAGRAMMING\xpath-3.1\build.ps1  
echo "***"
echo "================================================================= end xpath-3.1 ====================="
echo "."

