# 

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
echo " & $SOURCEFLEXDIAGRAMMING\xslt\build.ps1        xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"       
echo "***"
echo "================================================================= end flexDiagram xslt ====================="
echo "."

echo "."
echo "================================================================= begin flexDiagram xslt template ==================="
echo "***"
echo " & $SOURCEFLEXDIAGRAMMING\xslt_templates\build.ps1     xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
echo "***"
echo "================================================================= begin flexDiagram xslt template ====================="
echo "."
