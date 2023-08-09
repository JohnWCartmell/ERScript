. ..\buildscripts\setBuildtimePathVariables.ps1

echo ("*** building from  $SOURCE metaModel folder")

$SOURCEXML = $SOURCE + '\entitymodellingbook'
$TARGETTEMP = $TARGET + '\temp'
$TARGETWWW = $TARGET + '\www.entitymodelling.org'
$TARGETXSLT = $TARGET + '\documentSupport\xslt'

# CREATE target temp folder if it doesn't already exist
If(!(test-path -PathType container $TARGETTEMP))
{
      echo ('CREATING target folder ' + $TARGETTEMP)
      New-Item -ItemType Directory -Path $TARGETTEMP
}

# CREATE target folder if it doesn't already exist
If(!(test-path -PathType container $TARGETWWW))
{
      echo ('CREATING target folder ' + $TARGETWWW)
      New-Item -ItemType Directory -Path $TARGETWWW
}

########## CHECK OTHER build.ps ####
echo "copy .htaccess.txt"
copy .htaccess.txt $TARGETWWW\.htaccess.txt

java -jar %SAXON_JAR% -s:"%filepath%%filenamebase%.xml" -xsl:%ERHOME%\xslt\documentERmodel.elaboration.xslt -o:temp\%filenamebase%.elaborated.xml

java -jar %SAXON_JAR% -s:temp\%filenamebase%.elaborated.xml -xsl:%ERHOME%\documentSupport\xslt\documentERmodel.complete.xslt -o:temp\%filenamebase%.completed.xml

java -jar %JING_PATH%\jing.jar -f %ERHOME%\documentModel\schemas\documentERmodel.rng temp\%filenamebase%.completed.xml


$TARGET\documentSupport\commands\copy_and_elaborate_and_schema_check  whole.xml www.entitymodelling.org

$TARGET\documentSupport\commands\doc2html temp\%filenamebase%.completed.xml www.entitymodelling.org

############## OLD ############### OLD ####################### OLD ###################### OLD ###

# COPY xml files
attrib -R $TARGETXML\*.xml
copy-item -Path $SOURCEXML\*.xml -Destination $TARGETXML
attrib +R $TARGETXML\*.xml
attrib -R $TARGETXML\*..physical.xml  #therse are generated therefore need be overwritable

pushd $TARGETXML

if ($false)
{
echo 'ERA.surface'
. $TARGET\scripts\buildExampleSVG.ps1 ERA.surface -animate -physicalType hs -longSeparator ... -shortSeparator .

echo 'Run surface ER.instanceValidation.xslt on logical model'
. $TARGET\scripts\ER.instanceValidation.ps1 ERA.surface..logical.xml -outputFolder ..\docs
} 

echo 'ERA'
. $TARGET\scripts\buildExampleSVG.ps1 ERA -animate -physicalType hs -longSeparator ... -shortSeparator . 

if ($false)
{
echo 'ERScript'
. $TARGET\scripts\buildExampleSVG.ps1 ERScript -animate -physicalType hs -longSeparator ... -shortSeparator . 

echo 'Run ER.instanceValidation.xslt on ERA physical model'
. $TARGET\scripts\ER.instanceValidation.ps1 ERA..physical.xml -outputFolder ..\docs -debugSwitch

echo 'Run ER.instanceValidation.xslt on ERScript physical model'
. $TARGET\scripts\ER.instanceValidation.ps1 ERScript..physical.xml -outputFolder ..\docs -debugSwitch

echo 'run genSVG.ps1 pullback_constraint.projection_rel..primary_scope.xml'
. $TARGET\scripts\genSVG.ps1 pullback_constraint.projection_rel..primary_scope.xml 

echo 'run genSVG.ps1 pullback_constraint.projection_rel..auxiliary_scope.xml'
. $TARGET\scripts\genSVG.ps1 pullback_constraint.projection_rel..auxiliary_scope.xml 

echo 'run genSVG.ps1 reference.inverse..primary_scope.xml'
. $TARGET\scripts\genSVG.ps1 reference.inverse..primary_scope.xml 

echo 'run genSVG.ps1 reference.inverse..auxiliary_scope.xml'
. $TARGET\scripts\genSVG.ps1 reference.inverse..auxiliary_scope.xml 

echo 'run genSVG.ps1 composition.inverse..primary_scope.xml'
. $TARGET\scripts\genSVG.ps1 composition.inverse..primary_scope.xml 

echo 'run genSVG.ps1 composition.inverse..auxiliary_scope.xml'
. $TARGET\scripts\genSVG.ps1 composition.inverse..auxiliary_scope.xml

echo 'run genSVG.ps1 step.direction..auxiliary_scope.xml'
. $TARGET\scripts\genSVG.ps1 step.direction..auxiliary_scope.xml

echo 'run genSVG.ps1 reference_constraint.supported_relationship..primary_scope.xml'
. $TARGET\scripts\genSVG.ps1 reference_constraint.supported_relationship..primary_scope.xml

echo 'ERA Diagrammed'
. $TARGET\scripts\buildExampleSVG.ps1 ERAdiagrammed -animate -physicalType hs -longSeparator ... -shortSeparator .

echo 'ERA Flex version'
. $TARGET\flexDiagramming\scripts\er2flex2svg.ps1 ERA..logical.xml -animate
}

popd 



