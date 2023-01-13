# run this from the xml folder which has the meta model src files:
# See  readme.md for an explanation of the source files.


$commandFolder=Split-Path $MyInvocation.MyCommand.Path

. ($commandFolder +'\set_path_variables.ps1')

powershell -Command "$ERHOME\scripts\buildExampleSVG.ps1  ERA  -physicalType hs -animate -outputFolder $TARGET/MetaModel"

powershell -Command "$ERHOME\scripts\buildExampleSVG.ps1  ERAdiagrammed  -physicalType hs -animate"
