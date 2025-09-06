
function ReplacexPwithxetc
{
    param($string)
    return $string -creplace 'xP',    'x'  `
                -creplace 'yP',    'y'  `
                -creplace 'wP',    'w'  `
                -creplace 'wlP',   'wl'  `
                -creplace 'wrP',   'wr' `
                -creplace 'wminP', 'wmin' `
                -creplace 'hP',     'h' `
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
                -creplace 'TopEdgeP', 'TopEdge' `
                -creplace 'BottomEdgeP', 'BottomEdge' `
                -creplace 'stringwidth_from_text_styleP', 'stringwidth_from_text_style' `
                -creplace 'x_lower_boundP', 'x_lower_bound' `
                -creplace 'x_upper_boundP', 'x_upper_bound' `
                -creplace 'left_sideP', 'left_side' `
                -creplace 'right_sideP', 'right_side' `
                -creplace 'annotate_rightQ', 'annotate_right' `
                -creplace 'annotate_leftQ', 'annotate_left' `
                -creplace 'deltayP', 'deltay' `
                -creplace 'label_lateral_offsetP', 'label_lateral_offset' `
                -creplace 'label_long_offsetP', 'label_long_offset' `
                      -creplace '40P', '40' `
                      -creplace '40.1P', '40.1' `
                      -creplace '40.5P', '40.5' `
                      -creplace '40.6P', '40.6' `
                      -creplace '42P',   '42' `
                      -creplace '42.1P',   '42.1' `
                      -creplace '42.11P',   '42.11' `
                      -creplace '50P',   '50' `
                      -creplace '50.1P',   '50.1' `
                      -creplace '50.2P',   '50.2' `
                      -creplace '51P',   '51' `
                      -creplace '52P',   '52' `
                      -creplace '55P',   '55' `
                      -creplace '56P',   '56' `
                      -creplace '60P',   '60' `
                      -creplace '140P', '140.1' `
                      -creplace '169P', '169' `
                      -creplace '170P', '170' `
                      -creplace '171P', '171' `
                      -creplace '172P', '172' `
                      -creplace '173P', '173' `
                      -creplace '240P', '240' `
                      -creplace '260P', '260' `
                      -creplace '262P', '262' `
                      -creplace '340P', '340' `
                      -creplace '342P', '342' `
                      -creplace '350P', '350' 
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
                    -creplace 'hP',     'w' `
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
                    -creplace 'TopEdgeP', 'LeftSide' `
                    -creplace 'BottomEdgeP', 'RightSide' `
                    -creplace 'stringwidth_from_text_styleP', 'stringheight_from_text_style' `
                    -creplace 'x_lower_boundP', 'y_lower_bound' `
                    -creplace 'x_upper_boundP', 'y_upper_bound' `
                    -creplace 'left_sideP', 'top_edge' `
                    -creplace 'right_sideP', 'bottom_edge' `
                    -creplace 'annotate_rightQ', 'annotate_low' `
                    -creplace 'annotate_leftQ', 'annotate_high' `
                    -creplace 'deltayP', 'deltax' `
                -creplace 'label_lateral_offsetP', 'label_long_offset' `
                -creplace 'label_long_offsetP', 'label_lateral_offset' `
                      -creplace '40P', '41' `
                      -creplace '40.1P', '41.1' `
                      -creplace '40.5P', '41.5' `
                      -creplace '40.6P', '41.6' `
                      -creplace '42P', '43' `
                      -creplace '42.1P', '43.1' `
                      -creplace '42.11P', '43.11' `
                      -creplace '50P', '48' `
                      -creplace '50.1P', '48.1' `
                      -creplace '50.2P', '48.2' `
                      -creplace '51P', '49' `
                      -creplace '52P', '53' `
                      -creplace '55P', '57' `
                      -creplace '56P', '58' `
                      -creplace '60P', '61' `
                      -creplace '140P', '140.2' `
                      -creplace '169P', '179' `
                      -creplace '170P', '180' `
                      -creplace '171P', '181' `
                      -creplace '172P', '182' `
                      -creplace '173P', '183' `
                      -creplace '240P', '241' `
                      -creplace '260P', '261' `
                      -creplace '262P', '262' `
                      -creplace '340P', '341' `
                      -creplace '342P', '343' `
                      -creplace '350P', '351' 
}

$commandFolder=Split-Path $MyInvocation.MyCommand.Path

. ($commandFolder +'\..\..\buildscripts\setBuildtimePathVariables.ps1')


echo ("*** building from  $SOURCE flexDiagramming xslt folder")

$SOURCEXSLT = $SOURCE + '\flexDiagramming\xslt_templates'
$TARGETXSLT = $TARGET + '\flexDiagramming\xslt'

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
