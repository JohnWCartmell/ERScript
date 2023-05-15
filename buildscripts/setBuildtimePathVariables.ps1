$commandDir = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
$SOURCE="$commandDir\.."

$TARGET="$SOURCE\..\..\BuildArea\ERScript"
$SAXON_PATH="$BUILDAREA\thirdparty\SaxonHE11-4J"
$SAXON_JAR_NAME="saxon-he-11.4.jar"
$SAXON_JAR="$SAXON_PATH\$SAXON_JAR_NAME"
$JING_PATH="$DISTRIBUTION_BUILDAREA\thirdparty\jing-20091111\bin"

