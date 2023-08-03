
Param(
   [Parameter(Mandatory=$False)]
       [string]$filename
)

$commandFolder=Split-Path $MyInvocation.MyCommand.Path

. ($commandFolder + '\..\buildscripts\setBuildtimePathVariables.ps1')

$EXAMPLEFOLDERNAME='exampleDataModels'

$SOURCEXML = $SOURCE  +  '\' + $EXAMPLEFOLDERNAME

$TARGETXML = $TARGET + '\' + $EXAMPLEFOLDERNAME +'\xml'
$TARGETDOCS = $TARGET + '\' + $EXAMPLEFOLDERNAME + '\docs'

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
      if ($PSBoundParameters.ContainsKey('filename') -and ($file.Extension -eq '.xml')) {
      echo 'copy single xml file'
      copy-item -Path $SOURCEXML\$filename -Destination $TARGETDOCS
      } else {
      #copy all files 
      copy-item -Path $SOURCEXML\*.xml -Destination $TARGETXML
      copy-item -Path $SOURCEXML\*.html -Destination $TARGETDOCS
      }
}

pushd $TARGETXML
if ($PSBoundParameters.ContainsKey('filename')-and ($filename -ne 'build.ps1')){
. $TARGET\scripts\buildLegacySVG $filename -physicalType h -shortSeparator . -longSeparator ...
}else{
    echo 'building all'
    get-ChildItem -Path *.xml -Exclude *..physical.xml | Foreach-Object {
      echo 'building ' + $_.Name
      . $TARGET\scripts\buildLegacySVG $_.Name -physicalType h -shortSeparator . -longSeparator ...
    }
    echo 'done building all'
}
popd 
