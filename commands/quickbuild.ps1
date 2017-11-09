
Param(
   [switch] $l,
   [switch] $p,
   [Parameter(Mandatory=$True)]
       [string]$modelSourceFileName
)


copy-item ..\..\..\..\GitHub\ERModelSeries1\examplesConceptual\src\$modelSourceFileName $modelSourceFileName

cmd /c call ..\..\ERmodel_v1.4\scripts\gen_downgrade_to_v1.3 $modelSourceFileName

if ($l) {
   cmd /c call ..\..\ERmodel_v1.4\scripts\genSvg $modelSourceFileName
}
if ($p) {
   cmd /c call ..\..\ERmodel_v1.4\scripts\generate_physicalandlog $modelSourceFileName
}
