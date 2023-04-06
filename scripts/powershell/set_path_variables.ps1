$commandDir = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
$ERHOME="$commandDir\.."
$DISTRIBUTION="$ERHOME\.."
$SAXON_PATH="$DISTRIBUTION\thirdparty\SaxonHE11-5J"
$SAXON_JAR_NAME="saxon-he-11.5.jar"
$SAXON_JAR="$SAXON_PATH\$SAXON_JAR_NAME"
$JING_PATH="$DISTRIBUTION\thirdparty\jing-20091111\bin"