
function ReplacexPwithxetc
{
    param($string)
    return $string -creplace 'xP',    'x'  `
                -creplace 'yP',    'y'  `
                -creplace 'wP',    'w'  `
                -creplace 'wlP',   'wl'  `
                -creplace 'wrP',   'wr' `
                -creplace 'wminP', 'wmin' `
                -creplace 'ewQ',   'ew' `
                -creplace 'nsP',   'ns' `
                -creplace 'startxP', 'startx' `
                -creplace 'midxP', 'midx' `
                -creplace 'deltaxP', 'deltax' `
                -creplace 'deltayP', 'deltay' `
                -creplace 'endxP',  'endx' `
                -creplace 'tanP', 'tan' `
                -creplace 'rightP', 'right' `
                -creplace 'centreP', 'centre' `
                -creplace 'leftP', 'left' `
                -0ace 'deltayP', 'deltay' 
}

function ReplacexPwithyetc
{
    param($string)
    return $string -creplace 'xP',    'y'  `
                      -creplace 'yP',    'x'  `
                      -creplace 'wP',    'h'  `
                      -creplace 'wlP',   'ht'  `
                      -creplace 'wrP',   'hb' `
                                -creplace 'wminP', 'hmin' `
                                -creplace 'ewQ',   'ns' `
                                -creplace 'nsP',   'ew' `
                                -creplace 'startxP', 'starty' `
                                -creplace 'midxP', 'midy' `
                                -creplace 'deltaxP', 'deltay' `
                                -creplace 'deltayP', 'deltax' `
                                -creplace 'tanP', 'cotan' `
                                -creplace 'endxP',  'endy' `
                      -creplace 'leftP', 'top' `
                      -creplace 'centreP', 'middle' `
                                -creplace 'rightP', 'bottom' `
                                -creplace 'stringwidthP', 'stringheight' `
                                -creplace 'stringwidthP', 'stringheight' `
                                -creplace 'x_lower_boundP', 'y_lower_bound' `
                                -creplace 'x_upper_boundP', 'y_upper_bound' `
                                -creplace 'left_sideP', 'top_edge' `
                                -creplace 'right_sideP', 'bottom_edge' `
                                -creplace 'annotate_rightQ', 'annotate_low' `
                                -creplace 'annotate_leftQ', 'annotate_high' `
                                -creplace 'deltayP', 'deltax' 
}

$commandFolder=Split-Path $MyInvocation.MyCommand.Path

. ($commandFolder +'\..\..\buildscripts\setBuildtimePathVariables.ps1')


echo ("*** building from  $SOURCE flexDiagramming xslt folder")

$SOURCEXSLT = $SOURCE + '\flexDiagramming\xslt_templates'
$TARGETXSLT = $TARGET + '\xslt'

# CREATE target xslt folder if it doesn't already exist
If(!(test-path -PathType container $TARGETXSLT))
{
      echo ('CREATING target xslt folder ' + $TARGETXSLT)
      New-Item -ItemType Directory -Path $TARGETXSLT
}

# COPY xslt files
attrib -R $TARGETXSLT\*.xslt
Get-ChildItem "$SOURCEXSLT" -Filter *.xslt | 
Foreach-Object {
    $filename = $_.Name 
    $nameOfFileTransformedxDim = ReplacexPwithxetc($filename)
    $nameOfFileTransformedyDim = ReplacexPwithyetc($filename)

    echo ('producing ' + $nameOfFileTransformedxDim +' & ' + $nameOfFileTransformedyDim)

    $INPUT = (Get-Content $_.FullName) 

    $OUTPUTxDim = ReplacexPwithxetc($INPUT)
    Set-Content -Path ($TARGETXSLT + '\' + $nameOfFileTransformedxDim) -Value $OUTPUTxDim

    $OUTPUTyDim = ReplacexPwithyetc($INPUT)
    Set-Content -Path ($TARGETXSLT + '\' + $nameOfFileTransformedyDim) -Value $OUTPUTyDim
}
attrib +R $TARGETXSLT\*.xslt
