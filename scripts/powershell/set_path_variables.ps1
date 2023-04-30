$commandDir = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
$ERHOME="$commandDir\.."
$DISTRIBUTION="$ERHOME\.."
$SAXON_PATH="$DISTRIBUTION\thirdparty\SaxonHE12-1J"
$SAXON_JAR_NAME="saxon-he-12.1.jar"
$SAXON_JAR="$SAXON_PATH\$SAXON_JAR_NAME"
$JING_PATH="$DISTRIBUTION\thirdparty\jing-20091111\bin"