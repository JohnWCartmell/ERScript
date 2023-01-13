
Param(
   [Parameter(Mandatory=$True)]
       [string]$SourceFileName,
	[Parameter(Mandatory=$True)]
       [string]$OutFileName
)

(gc $SourceFileName)                       `
                      -creplace 'xP',    'x'  `
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
					  -creplace 'stringwidthP', 'stringwidth' `
					  -creplace 'x_lower_boundP', 'x_lower_bound' `
					  -creplace 'x_upper_boundP', 'x_upper_bound' `
					  -creplace 'left_sideP', 'left_side' `
					  -creplace 'right_sideP', 'right_side' `
					  -creplace 'annotate_rightQ', 'annotate_right' `
					  -creplace 'annotate_leftQ', 'annotate_left' `
					  -creplace 'deltayP', 'deltay' `
					  -creplace '40P', '40' `
					  -creplace '42P',   '42' `
					  -creplace '50P',   '50' `
					  -creplace '51P',   '51' `
					  -creplace '52P',   '52' `
					  -creplace '55P',   '55' `
					  -creplace '56P',   '56' `
					  -creplace '60P',   '60' `
					  -creplace '169P', '169' `
					  -creplace '170P', '170' `
					  -creplace '171P', '171' `
					  -creplace '172P', '172' `
					  -creplace '173P', '173' `
                                 | Out-File -encoding ASCII $OutFileName
