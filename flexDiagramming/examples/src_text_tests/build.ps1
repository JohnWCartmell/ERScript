
Param(
   [Parameter(Mandatory=$False)]
       [string]$filename
)

$commandFolder=Split-Path $MyInvocation.MyCommand.Path

. ($commandFolder + '\..\..\..\buildscripts\setBuildtimePathVariables.ps1')

$EXAMPLEFOLDERNAME='src_instruction'

$SOURCEXML = $SOURCE + '\flexDiagramming\examples\' +  $EXAMPLEFOLDERNAME

$TARGETXML = $TARGET + '\flexDiagramming\examples\' +  $EXAMPLEFOLDERNAME

# CREATE target folder if it doesn't already exist
If(!(test-path -PathType container $TARGETXML))
{
      echo ('CREATING target folder ' + $TARGETXML)
      New-Item -ItemType Directory -Path $TARGETXML
}

# COPY xml files
attrib -R $TARGETXML\*.xml
echo ('filename is ' + $filename)
if ($PSBoundParameters.ContainsKey('filename') -and ($filename -ne 'build.ps1')){
echo 'copy single file'
copy-item -Path $SOURCEXML\$filename -Destination $TARGETXML
} else {
copy-item -Path $SOURCEXML\*.xml -Destination $TARGETXML
}

attrib +R $TARGETXML\*.xml

$SOURCESHAREDXML = $SOURCEXML + '\shared'
$TARGETSHAREDXML = $TARGETXML + '\shared'

# CREATE shared folder if it doesn't already exist
If(!(test-path -PathType container $TARGETSHAREDXML))
{
      echo ('CREATING shared target  folder ' + $TARGETSHAREDXML)
      New-Item -ItemType Directory -Path $TARGETSHAREDXML
}

# COPY xml files
attrib -R $TARGETSHAREDXML\*.xml
copy-item -Path $SOURCESHAREDXML\*.xml -Destination $TARGETSHAREDXML
attrib +R $TARGETSHAREDXML\*.xml

pushd $TARGETXML
if ($PSBoundParameters.ContainsKey('filename')-and ($filename -ne 'build.ps1')){
. $TARGET\flexDiagramming\scripts\buildexample $filename
}else{
. $TARGET\flexDiagramming\scripts\buildAllExamples
}
popd 
