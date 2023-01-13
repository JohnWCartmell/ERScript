echo ("*** building from  source $SOURCE latex folder")

$SOURCELATEX = $SOURCE + '\latex'
$TARGETLATEX = $TARGET + '\latex'

# CREATE target latex folder if it doesn't already exist
If(!(test-path -PathType container $TARGETLATEX))
{
      echo ('CREATING target latex folder ' + $TARGETLATEX)
      New-Item -ItemType Directory -Path $TARGETLATEX
}

# COPY tex files
attrib -R $TARGETLATEX\*.tex
copy-item -Path $SOURCELATEX\*.tex -Destination $TARGETLATEX
attrib +R $TARGETLATEX\*.tex
# COPY txt files
attrib -R $TARGETLATEX\*.txt
copy-item -Path $SOURCELATEX\*.txt -Destination $TARGETLATEX
attrib +R $TARGETLATEX\*.txt