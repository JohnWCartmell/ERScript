
$commandFolder=Split-Path $MyInvocation.MyCommand.Path

. ($commandFolder + '\..\buildscripts\setBuildtimePathVariables.ps1')

echo ("*** building from  $SOURCE flexDiagramming folder")

$EXAMPLESSOURCE = $SOURCE + '\examplesSelected'

echo "."
echo "=============================== begin brinton ==================="
echo "***"
& $EXAMPLESSOURCE\brinton\build.ps1                # NOTE THAT '&' is the powershell call operator
echo "***"
echo "=============================== end brinton ====================="

echo "."
echo "=============================== begin chenManufacturingCo ==================="
echo "***"
& $EXAMPLESSOURCE\chenManufacturingCo\build.ps1                # NOTE THAT '&' is the powershell call operator
echo "***"
echo "=============================== end chenManufacturingCo ====================="

echo "."
echo "=============================== begin chromatogramAnalysisRecord ==================="
echo "***"
& $EXAMPLESSOURCE\chromatogramAnalysisRecord\build.ps1  
echo "***"
echo "=============================== end chromatogramAnalysisRecord ====================="

echo "."
echo "=============================== begin contractBridge ==================="
echo "***"
& $EXAMPLESSOURCE\contractBridge\build.ps1  
echo "***"
echo "=============================== end contractBridge ====================="

echo "."
echo "=============================== begin cricket ==================="
echo "***"
& $EXAMPLESSOURCE\cricket\build.ps1  
echo "***"
echo "=============================== end cricket ====================="

echo "."
echo "=============================== begin goodlandsSSADMcarHire ==================="
echo "***"
& $EXAMPLESSOURCE\goodlandsSSADMcarHire\build.ps1  
echo "***"
echo "=============================== end goodlandsSSADMcarHire ====================="

echo "."
echo "=============================== begin grids ==================="
echo "***"
& $EXAMPLESSOURCE\grids\build.ps1  
echo "***"
echo "=============================== end grids ====================="

echo "."
echo "=============================== begin orderEntry ==================="
echo "***"
& $EXAMPLESSOURCE\orderEntry\build.ps1  
echo "***"
echo "=============================== end orderEntry ====================="

echo "."
echo "=============================== begin relationalMetaModel3 ==================="
echo "***"
& $EXAMPLESSOURCE\relationalMetaModel3\build.ps1  
echo "***"
echo "=============================== end relationalMetaModel3 ====================="

