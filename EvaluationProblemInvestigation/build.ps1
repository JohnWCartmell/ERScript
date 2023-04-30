. ..\buildscripts\setBuildtimePathVariables.ps1

echo ("*** building from  $SOURCE ERValidationTesting folder")

$SOURCEXML = $SOURCE + '\EvaluationProblemInvestigation'
$TARGETXML = $TARGET + '\EvaluationProblemInvestigation'


# CREATE target folder if it doesn't already exist
If(!(test-path -PathType container $TARGETXML))
{
      echo ('CREATING target folder ' + $TARGETXML)
      New-Item -ItemType Directory -Path $TARGETXML
}

# COPY xml files
attrib -R $TARGETXML\*.xml
copy-item -Path $SOURCEXML\*.xml -Destination $TARGETXML

pushd $TARGETXML

echo $SAXON_JAR

java -Xss2m -jar ..\..\$SAXON_JAR -opt:0  -s:evaluationTest.xml `
                      -xsl:$SOURCEXML\validation.xslt `
                       -o:evaluationTestOutput.xml

popd 

attrib +R $TARGETXML\*.xml

