. ..\buildscripts\setBuildtimePathVariables.ps1

echo ("*** building from  $SOURCE entity modelling book folder")

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

echo "copy .htaccess.txt"
copy .htaccess.txt $TARGETWWW\.htaccess.txt

pushd $TARGETWWW

java -jar $SAXON_JAR -s:$SOURCEXML\whole.xml -xsl:$TARGET\xslt\documentERmodel.elaboration.xslt -o:$TARGETTEMP\whole.elaborated.xml

java -jar $SAXON_JAR -s:$TARGETTEMP\whole.elaborated.xml -xsl:$TARGETXSLT\documentERmodel.complete.xslt -o:$TARGETTEMP\whole.completed.xml

java -jar $JING_PATH\jing.jar -f $TARGET\documentModel\schemas\documentERmodel.rng $TARGETTEMP\whole.completed.xml

java -jar $SAXON_JAR -s:$TARGETTEMP\whole.completed.xml -xsl:$TARGETXSLT\document2.html.xslt -o:whole.html rootfolder=.

popd 



