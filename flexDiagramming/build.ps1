
$commandFolder=Split-Path $MyInvocation.MyCommand.Path

. ($commandFolder + '\..\buildscripts\setBuildtimePathVariables.ps1')

echo ("*** building from  $SOURCE css folder")

$SOURCEFLEXDIAGRAMMING = $SOURCE + '\flexDiagramming'

echo "."
echo "================================================================= begin flexDiagramModel ==================="
echo "***"
& $SOURCEFLEXDIAGRAMMING\flexDiagramModel\build.ps1                # NOTE THAT '&' is the powershell call operator
echo "***"
echo "================================================================= end flexDiagramModel ====================="
echo "."

echo "."
echo "================================================================= begin flexDiagram xslt ==================="
echo "***"
& $SOURCEFLEXDIAGRAMMING\xslt\build.ps1  
echo "***"
echo "================================================================= end flexDiagram xslt ====================="
echo "."

echo "."b
echo "================================================================= begin flexDiagram xslt template ==================="
echo "***"
& $SOURCEFLEXDIAGRAMMING\xslt_templates\build.ps1
echo "***"
echo "================================================================= end flexDiagram xslt template ====================="
echo "."
