$commandDir = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent

echo ("*** commandDir  $commandDir")
$SOURCE="$commandDir/.."
$DISTRIBUTION_BUILDAREA="$SOURCE/../../BuildArea"
$TARGET="$DISTRIBUTION_BUILDAREA/ERScript"
$SAXON_PATH="$DISTRIBUTION_BUILDAREA/thirdparty/SaxonHE12-5J"
echo ("*** SAXON_PATH  $SAXON_PATH")

$SAXON_JAR_NAME="saxon-he-12.5.jar"
$SAXON_JAR="$SAXON_PATH/$SAXON_JAR_NAME"
$JING_PATH="$DISTRIBUTION_BUILDAREA/thirdparty/jing-20091111\bin"

