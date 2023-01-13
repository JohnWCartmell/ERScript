# 

$commandFolder=Split-Path $MyInvocation.MyCommand.Path

. ($commandFolder + '\buildscripts\setBuildtimePathVariables.ps1')

echo ('SOURCE:' +  $SOURCE)
echo ('TARGET:' +  $TARGET)


# CREATE target folder if it doesn't already exist
If(!(test-path -PathType container $TARGET))
{
      echo ('CREATING target folder ' + $TARGET)
      New-Item -ItemType Directory -Path $TARGET
}
echo "."
echo "================================================================= begin html ==================="
echo "***"
& $SOURCE\html\build.ps1                # NOTE THAT '&' is the powershell call operator
echo "***"
echo "================================================================= end html ====================="
echo "."

echo "."
echo "================================================================= begin css ==================="
echo "***"
& $SOURCE\css\build.ps1                
echo "***"
echo "================================================================= end css ====================="
echo "."

echo "."
echo "================================================================= begin js ==================="
echo "***"
& $SOURCE\js\build.ps1     
echo "***"
echo "================================================================= end js ====================="
echo "."

echo "."
echo "================================================================= begin latex ==================="
echo "***"
& $SOURCE\latex\build.ps1     
echo "***"
echo "================================================================= end latex ====================="
echo "."

echo "."
echo "================================================================= begin scripts ==================="
echo "***"
& $SOURCE\scripts\build.ps1     
echo "***"
echo "================================================================= end scripts ====================="
echo "."

echo "."
echo "================================================================= begin xslt ==================="
echo "***"
& $SOURCE\xslt\build.ps1     
echo "***"
echo "================================================================= end xslt ====================="
echo "."

echo "."
echo "================================================================= begin metaModel ==================="
echo "***"
& $SOURCE\metaModel\build.ps1     
echo "***"
echo "================================================================= end metaModel ====================="
echo "."

echo "."
echo "================================================================= begin flexDiagrammming ==================="
echo "***"
& $SOURCE\flexDiagramming\build.ps1     
echo "***"
echo "================================================================= end flexDiagrammming ====================="
echo "."

echo "."
echo "================================================================= begin examplesSelected ==================="
echo "***"
& $SOURCE\examplesSelected\build.ps1     
echo "***"
echo "================================================================= end examplesSelected ====================="
echo "."
