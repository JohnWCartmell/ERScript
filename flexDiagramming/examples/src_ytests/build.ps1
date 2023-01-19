
Param(
   [Parameter(Mandatory=$False)]
       [string]$filename
)

$commandFolder=Split-Path $MyInvocation.MyCommand.Path

. ($commandFolder + '\..\..\..\buildscripts\setBuildtimePathVariables.ps1')

$EXAMPLEFOLDERNAME='src_ytests'

$SOURCEXML = $SOURCE + '\flexDiagramming\examples\' +  $EXAMPLEFOLDERNAME

$TARGETXML = $TARGET + '\flexDiagramming\examples\' +  $EXAMPLEFOLDERNAME
$TARGETDOCS = $TARGET + '\flexDiagramming\examples\' +  $EXAMPLEFOLDERNAME + '\docs'

$file=Get-Item $filename
echo ('basename is:' + $file.Basename) 
echo ('extension is:' + $file.Extension)

# CREATE target xml folder if it doesn't already exist
If(!(test-path -PathType container $TARGETXML))
{
      echo ('CREATING target folder ' + $TARGETXML)
      New-Item -ItemType Directory -Path $TARGETXML
}

# CREATE target docs folder if it doesn't already exist
If(!(test-path -PathType container $TARGETDOCS))
{
      echo ('CREATING target folder ' + $TARGETDOCS)
      New-Item -ItemType Directory -Path $TARGETDOCS
}


# COPY files
attrib -R $TARGETXML\*.xml
echo ('filename is ' + $filename)
if ($PSBoundParameters.ContainsKey('filename') -and ($file.Extension -eq '.xml')){
echo 'copy single xml file'
copy-item -Path $SOURCEXML\$filename -Destination $TARGETXML
} else {
      if ($PSBoundParameters.ContainsKey('filename') -and ($file.Extension -eq '.html')) {
      echo 'copy single html file'
      copy-item -Path $SOURCEXML\$filename -Destination $TARGETDOCS
      } else {
      #copy all files 
      copy-item -Path $SOURCEXML\*.xml -Destination $TARGETXML
      copy-item -Path $SOURCEXML\*.html -Destination $TARGETDOCS
      }
}

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
