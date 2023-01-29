
$commandFolder=Split-Path $MyInvocation.MyCommand.Path

. ($commandFolder + '\..\buildscripts\setBuildtimePathVariables.ps1')

echo ("*** building from  $SOURCE flexDiagramming folder")

$SOURCEFLEXDIAGRAMMING = $SOURCE + '\flexDiagramming'

echo "."
echo "================================================================= begin flexDiagramModel ==================="
echo "***"
& $SOURCEFLEXDIAGRAMMING\flexDiagramModel\build.ps1                # NOTE THAT '&' is the powershell call operator
echo "***"
echo "================================================================= end flexDiagramModel ====================="
echo "."

echo "."
echo "================================================================= begin flexDiagramming xslt ==================="
echo "***"
& $SOURCEFLEXDIAGRAMMING\xslt\build.ps1  
echo "***"
echo "================================================================= end flexDiagramming xslt ====================="
echo "."

echo "."
echo "================================================================= begin flexDiagramming methods ==================="
echo "***"
& $SOURCEFLEXDIAGRAMMING\methods\build.ps1  
echo "***"
echo "================================================================= end flexDiagramming methods ====================="
echo "."

echo "."
echo "================================================================= begin flexDiagramming xslt templates ==================="
echo "***"
& $SOURCEFLEXDIAGRAMMING\xslt_templates\build.ps1
echo "***"
echo "================================================================= end flexDiagramming xslt templates ====================="
echo "."

echo "."
echo "================================================================= begin flexDiagramming scripts ==================="
echo "***"
& $SOURCEFLEXDIAGRAMMING\scripts\build.ps1
echo "***"
echo "================================================================= end flexDiagramming srcipts  ====================="
echo "."

echo "."
echo "================================================================= begin flexDiagrmming examples ==================="
echo "***"
& $SOURCEFLEXDIAGRAMMING\examples\build.ps1
echo "***"
echo "================================================================= end flexDiagramming examples  ====================="
echo "."
