. ..\buildscripts\setBuildtimePathVariables.ps1

echo ("*** building from  $SOURCE css folder")

$SOURCEXML = $SOURCE + '\examplesSelected'
$TARGETXML = $TARGET + '\examplesSelected\xml'


# CREATE target folder if it doesn't already exist
If(!(test-path -PathType container $TARGETXML))
{
      echo ('CREATING target folder ' + $TARGETXML)
      New-Item -ItemType Directory -Path $TARGETXML
}

# COPY xml files
attrib -R $TARGETXML\*.xml
copy-item -Path $SOURCEXML\*.xml -Destination $TARGETXML
attrib +R $TARGETXML\*.xml
attrib -R $TARGETXML\*..physical.xml    #these are generated and therefore need to be overwriteable

pushd $TARGETXML

echo 'Brinton Example'
. $TARGET\scripts\buildExampleSVG.ps1 brintonSimpleSentenceStructure -animate

echo 'Brinton Flex version'
. $TARGET\flexDiagramming\scripts\er2flex2svg.ps1 brintonSimpleSentenceStructure..logical.xml -animate

echo 'Cricket Example'
. $TARGET\scripts\buildExampleSVG.ps1 cricketMatch -animate -physicalType hs

echo 'Criket Flex version'
. $TARGET\flexDiagramming\scripts\er2flex2svg.ps1 cricketMatch..logical.xml -animate 

echo 'grid Example'
. $TARGET\scripts\buildExampleSVG.ps1 grids -animate -physicalType hs

echo 'grids Flex version'
. $TARGET\flexDiagramming\scripts\er2flex2svg.ps1 grids..logical.xml -animate

echo 'Relational Meta Model Example'
. $TARGET\scripts\buildExampleSVG.ps1 relationalMetaModel3 -animate -physicalType r 

echo 'Relational Meta Model Flex version'
. $TARGET\flexDiagramming\scripts\er2flex2svg.ps1 relationalMetaModel3..logical.xml -animate -debugswitch

popd 



