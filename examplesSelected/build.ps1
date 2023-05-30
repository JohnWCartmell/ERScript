
$commandFolder=Split-Path $MyInvocation.MyCommand.Path

. ($commandFolder + '\..\buildscripts\setBuildtimePathVariables.ps1')

echo ("*** building from  $SOURCE flexDiagramming folder")

$EXAMPLESSOURCE = $SOURCE + '\examplesSelected'

echo "."
echo "================================================================= begin brinton ==================="
echo "***"
& $EXAMPLESSOURCE\brinton\build.ps1                # NOTE THAT '&' is the powershell call operator
echo "***"
echo "================================================================= end brinton ====================="
echo "."

echo "."
echo "================================================================= begin cricket ==================="
echo "***"
& $EXAMPLESSOURCE\cricket\build.ps1  
echo "***"
echo "================================================================= end cricket ====================="
echo "."

echo "."
echo "================================================================= begin grids ==================="
echo "***"
& $EXAMPLESSOURCE\grids\build.ps1  
echo "***"
echo "================================================================= end grids ====================="

echo "."

echo "."
echo "================================================================= begin relationalMetaModel3 ==================="
echo "***"
& $EXAMPLESSOURCE\relationalMetaModel3\build.ps1  
echo "***"
echo "================================================================= end relationalMetaModel3 ====================="
echo "."

echo "."
echo "================================================================= begin chromatogramAnalysisRecord ==================="
echo "***"
& $EXAMPLESSOURCE\chromatogramAnalysisRecord\build.ps1  
echo "***"
echo "================================================================= end chromatogramAnalysisRecord ====================="
echo "."

