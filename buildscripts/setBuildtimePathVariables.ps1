$commandDir = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
$SOURCE="$commandDir\.."
$TARGET="$SOURCE\..\..\BuildArea\ERScript"
$SAXON_PATH="$BUILDAREA\thirdparty\SaxonHE12-1J"
$SAXON_JAR_NAME="saxon-he-12.`.jar"
$SAXON_JAR="$SAXON_PATH\$SAXON_JAR_NAME"
$JING_PATH="$DISTRIBUTION_BUILDAREA\thirdparty\jing-20091111\bin"

