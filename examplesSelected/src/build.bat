echo off

echo Brinton Example
echo =================
powershell ..\..\ERmodel_v1.6\scripts\buildExampleSVG.ps1 brintonSimpleSentenceStructure -animate

echo Cricket Example
echo =================
powershell ..\..\ERmodel_v1.6\scripts\buildExampleSVG.ps1 cricketMatch -physicalType hs -animate

echo grid Example
echo =================
powershell ..\..\ERmodel_v1.6\scripts\buildExampleSVG.ps1 grids -physicalType hs -animate

echo Relational Meta Model Example
echo =================
powershell ..\..\ERmodel_v1.6\scripts\buildExampleSVG.ps1 relationalMetaModel3 -physicalType r -animate