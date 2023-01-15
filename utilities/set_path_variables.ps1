$commandDir = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
$ERHOME="$commandDir\.."
$BUILDAREA="$ERHOME\..\..\BuildArea"
$SAXON_PATH="$BUILDAREA\thirdparty\SaxonHE11-4J"
$SAXON_JAR_NAME="saxon-he-11.4.jar"
$SAXON_JAR="$SAXON_PATH\$SAXON_JAR_NAME"
$JING_PATH="$BUILDAREA\thirdparty\jing-20091111\bin"