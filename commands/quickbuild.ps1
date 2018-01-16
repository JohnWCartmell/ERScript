
Param(
   [switch] $l,
   [switch] $p,
   [switch] $tex,
   [Parameter(Mandatory=$True)]
       [string]$modelSourceFileName
)

$commandDir = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent

. $commandDir\set_path_variables.ps1

"ERXSLT is $ERXSLT"

copy-item ..\..\..\..\GitHub\ERModelSeries1\examplesConceptual\src\$modelSourceFileName $modelSourceFileName

cmd /c call $ERHOME\scripts\gen_downgrade_to_v1.3 $modelSourceFileName

if ($l) {
   cmd /c call $ERHOME\scripts\genSvg $modelSourceFileName
   if ($tex) {
      cmd /c call $ERHOME\scripts\generate_texandlog $modelSourceFileName
   }
}
if ($p) {
   cmd /c call $ERHOME\scripts\generate_physicalandlog $modelSourceFileName
}
