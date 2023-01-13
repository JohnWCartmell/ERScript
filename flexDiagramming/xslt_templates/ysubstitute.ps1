
Param(
   [Parameter(Mandatory=$True)]
       [string]$SourceFileName,
	[Parameter(Mandatory=$True)]
       [string]$OutFileName
)

(gc $SourceFileName)                       `
                      -creplace 'xP',    'y'  `
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
					  -creplace 'deltayP', 'deltax' `
					  -creplace '40P', '41' `
					  -creplace '42P', '43' `
					  -creplace '50P', '48' `
					  -creplace '51P', '49' `
					  -creplace '52P', '53' `
					  -creplace '55P', '57' `
					  -creplace '56P', '58' `
					  -creplace '60P', '61' `
					  -creplace '169P', '179' `
					  -creplace '170P', '180' `
					  -creplace '171P', '181' `
					  -creplace '172P', '182' `
					  -creplace '173P', '183' `
                                 | Out-File -encoding ASCII $OutFileName
