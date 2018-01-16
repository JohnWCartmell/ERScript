$commandDir = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent

$ERModelversion='ERmodel_v1.4'
. $commandDir\..\$ERmodelversion\scripts\set_path_variables.ps1

$ERXSLT="$ERHOME\xslt"
$ERSCHEMA="$ERHOME\schema"

"hello world"
"ERXSLT is $ERXSLT"

