
$commandFolder=Split-Path $MyInvocation.MyCommand.Path

. ($commandFolder + '\..\..\buildscripts\setBuildtimePathVariables.ps1')

echo ("*** building from  $SOURCE flexDiagramming folder")

$SOURCEEXAMPLES = ($SOURCE + '\flexDiagramming\examples')

function buildFolder {
	param ( [string] $foldername)

echo "."
echo "================================================================= begin $foldername ==================="
echo "***"
& $SOURCEEXAMPLES\$foldername\build.ps1               
echo "================================================================= end $foldername ====================="
echo "."
}
buildFolder src_enclosures
buildFolder src_paths
buildFolder src_routes
buildFolder src_text_tests
buildFolder src_xtests
buildFolder src_ytests
buildFolder GoodlandCarHire
