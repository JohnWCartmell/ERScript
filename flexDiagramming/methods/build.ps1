
$commandFolder=Split-Path $MyInvocation.MyCommand.Path

. ($commandFolder + '\..\..\buildscripts\setBuildtimePathVariables.ps1')

echo ("*** building from  $SOURCE flexDiagramming methods folder")

$SOURCEERAMETHODFOLDER = ($SOURCE + '\flexDiagramming\methods')

function buildFolder {
	param ( [string] $foldername)
echo "."
echo "================================================================= begin $foldername ==================="
echo "***"
& $SOURCEERAMETHODFOLDER\$foldername\build.ps1               
echo "================================================================= end $foldername ====================="
echo "."
}

buildFolder era
buildFolder test

