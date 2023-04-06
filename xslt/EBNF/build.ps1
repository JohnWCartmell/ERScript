$commandFolder=Split-Path $MyInvocation.MyCommand.Path

. ($commandFolder + '\..\..\buildscripts\setBuildtimePathVariables.ps1')

echo ("*** building from  $SOURCE xslt EBNF folder")

$SOURCEXSLT = $SOURCE + '\xslt\EBNF'
$TARGETXSLT = $TARGET + '\xslt\EBNF'

# CREATE target xslt\EBNF folder if it doesn't already exist
If(!(test-path -PathType container $TARGETXSLT))
{
      echo ('CREATING target EBNF folder ' + $TARGETXSLT)
      New-Item -ItemType Directory -Path $TARGETXSLT
}

# COPY xslt files
attrib -R $TARGETXSLT\*.xslt
copy-item -Path $SOURCEXSLT\*.xslt -Destination $TARGETXSLT
attrib +R $TARGETXSLT\*.xslt


# COPY xpath files
attrib -R $TARGETXSLT\*.xpath
copy-item -Path $SOURCEXSLT\*.xpath -Destination $TARGETXSLT
attrib +R $TARGETXSLT\*.xpath
