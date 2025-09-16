$commandDir = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
$ERHOME="$commandDir/.."
echo "*** ERHOME  $ERHOME"
$DISTRIBUTION="$ERHOME/.."
$SAXON_PATH="$DISTRIBUTION/thirdparty/SaxonHE12-5J"

echo "*** SAXON_PATH $SAXON_PATH"
$SAXON_JAR_NAME="saxon-he-12.5.jar"
$SAXON_JAR="$SAXON_PATH/$SAXON_JAR_NAME" + ':' + "$DISTRIBUTION/thirdparty/xmlresolver-5.2.2.jar"
$JING_PATH="$DISTRIBUTION/thirdparty/jing-20091111/bin"
$env:ERScript="$ERHOME"