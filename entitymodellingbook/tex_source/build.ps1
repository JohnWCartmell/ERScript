
Param(
   [Parameter(Mandatory=$False)]
       [string]$filename
)

$commandFolder=Split-Path $MyInvocation.MyCommand.Path

. ($commandFolder + '\..\..\buildscripts\setBuildtimePathVariables.ps1')

$TEXSOURCEFOLDERNAME='tex_source'

$SOURCETEX = $SOURCE  +  '\entitymodellingbook\' + $TEXSOURCEFOLDERNAME

$TARGETPNGTEX = $TARGET + '\temp\images'
$TARGETTEX = $TARGET + '\docs\images'
$TARGETWWW = $TARGET + '\www.entitymodelling.org'
$TARGETPNG = $TARGETWWW + '\images'

$file=Get-Item $filename
echo ('basename is:' + $file.Basename) 
echo ('extension is:' + $file.Extension)
echo ('location: ' + (Get-Location) )

# CREATE target tex folder if it doesn't already exist
If(!(test-path -PathType container $TARGETPNGTEX))
{
      echo ('CREATING target folder ' + $TARGETPNGTEX)
      New-Item -ItemType Directory -Path $TARGETPNGTEX
}

# CREATE target png images folder if it doesn't already exist
If(!(test-path -PathType container $TARGETPNG))
{
      echo ('CREATING target folder ' + $TARGETPNG)
      New-Item -ItemType Directory -Path $TARGETPNG
}

# This function called from tex source folder
function Wrap-TexFile {
    param (
        $FileName
    )
    echo('Wrapping ' +  $FileName)
    Get-Content ambles/preamble.txt, $Filename, ambles/postamble.txt | Set-Content $TARGETPNGTEX\$Filename
}

# This function called from $TARGETPNGTEX folder 
function Build-File {
    param (
        $FileName
    )
    echo('Building ' +  $FileName)

    $file = Get-ChildItem $FileName

    $basename = $file.BaseName

    echo ('BaseName: ' + $basename )
    latex $filename
    dvips -P pdf ($basename + '.dvi') 
    ps2pdf ($basename + '.ps') 
    convert -density 1000x1000 ($basename + '.pdf')  -quality 95 ($TARGETPNG + '\' + $basename + '.png')  
}

# Wrap one or more tex files into temp buld area
attrib -R $TARGETTEX\*.tex
echo ('filename is ' + $filename)
if ($PSBoundParameters.ContainsKey('filename') -and ($file.Extension -eq '.tex')){
    echo 'copy and wrap single tex file'
    Wrap-TexFile -FileName $filename
    copy-item -Path $filename -Destination $TARGETTEX
} else { 
        echo 'copying and wrapping all'
        get-ChildItem -Path *.tex  | Foreach-Object {
            echo ('need build from ' + $_.Name)
            Wrap-TexFile -FileName $_.Name
            copy-item -Path $_.Name -Destination $TARGETTEX
        }
        echo 'done copying and wrapping all'
}


pushd $TARGETPNGTEX
echo ('*********** location: ' + (Get-Location) )
if ($PSBoundParameters.ContainsKey('filename')-and ($filename -ne 'build.ps1')){
    echo ('need build from' + $filename)
    Build-File -FileName $filename
}else{
    echo 'building all'
    get-ChildItem -Path *.tex  | Foreach-Object {
      echo ('need build from ' + $_.Name)
      Build-File -FileName $_.Name

    }
    echo 'done building all'
}
popd 



