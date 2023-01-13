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

pushd $TARGETXML

echo 'Brinton Example'
. $TARGET\scripts\buildExampleSVG.ps1 brintonSimpleSentenceStructure -animate

echo 'Cricket Example'
. $TARGET\scripts\buildExampleSVG.ps1 cricketMatch -animate -physicalType hs

echo 'grid Example'
. $TARGET\scripts\buildExampleSVG.ps1 grids -animate -physicalType hs

echo 'Relational Meta Model Example'
. $TARGET\scripts\buildExampleSVG.ps1 relationalMetaModel3 -animate -physicalType r 

popd 



