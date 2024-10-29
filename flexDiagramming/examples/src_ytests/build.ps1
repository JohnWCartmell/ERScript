
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
$file=Get-Item $filename
echo ('basename is:' + $file.Basename) 
echo ('extension is:' + $file.Extension)
echo 'copy single xml file'
copy-item -Path $SOURCEXML\$filename -Destination $TARGETXML
} else {
      if ($PSBoundParameters.ContainsKey('filename') -and ($file.Extension -eq '.html')) {
      echo 'copy single html file'
      copy-item -Path $SOURCEXML\$filename -Destination $TARGETDOCS
      } else {
      echo 'copy all xml files'
      copy-item -Path $SOURCEXML\*.xml -Destination $TARGETXML
      echo 'copy all html files'
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

# COPY shareed xml files
attrib -R $TARGETSHAREDXML\*.xml
copy-item -Path $SOURCESHAREDXML\*.xml -Destination $TARGETSHAREDXML
attrib +R $TARGETSHAREDXML\*.xml

#pushd $TARGETXML
#if ($PSBoundParameters.ContainsKey('filename')-and ($filename -ne 'build.ps1')){
#. $TARGET\flexDiagramming\scripts\flex2svg.ps1 $filename -debugswitch -animate
#}else{
#????
#}
#popd

# This function called from temp build folder 
function Build-File {
    param (
        $FileName
    )
    echo('Building ' +  $FileName)
   . $TARGET\flexDiagramming\scripts\flex2svg.ps1 $filename -debugswitch -animate
}



pushd $TARGETXML
echo ('*********** location: ' + (Get-Location) )
if ($PSBoundParameters.ContainsKey('filename')-and ($filename -ne 'build.ps1')){
    echo ('need build from' + $filename)
    Build-File -FileName $filename
}else{
    echo 'building all'
    get-ChildItem -Path *.xml  | Foreach-Object {
      echo 'building ' + $_.Name
      Build-File -FileName $_.Name
    }
    echo 'done building all'
}
popd 
