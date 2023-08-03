
Param(
   [Parameter(Mandatory=$True)]

       [string]$imageSourceFilePath,
   [Parameter(Mandatory=$True)]
       [ValidateScript({
            if( -Not ($_ | Test-Path) ){
                throw "Folder does not exist"
            }
            return $true
        })]
       [string]$docHome,
   [Parameter(Mandatory=$True)]
          [ValidateScript({
            if( -Not ($_ | Test-Path) ){
                throw "Folder does not exist"
            }
            return $true
        })]
       [string]$ERHome
)

$dochomeunixstyle = $docHome.Replace("\","/")
$erhomeunixstyle = $ERHome.Replace("\","/")
$basename = (Get-Item $imageSourceFilePath).Basename
$imagesourcepath = (Get-Item $imageSourceFilePath).DirectoryName.Replace("\", "/")
$mainfilename = "temp\" + $basename + ".tex"


Set-Content $mainfilename "\documentclass[crop]{standalone}"
Add-Content $mainfilename  "\usepackage{preview}"
#
# Had problem with parentheses not being rendered when I used these packages
# Add-Content $mainfilename  "\usepackage{amsfonts}"
# Add-Content $mainfilename "\usepackage{amsmath}"
# Add-Content $mainfilename "\usepackage{mnsymbol}"
# (anyhow amsmath and amsfonts are included by ermacros)
# But problem is that mnsymbol (use for pitchfork symbol). This is not compatible with amsfont
# Now for a terrible work-around - I only need mnsymbol for the pitch fork used in "path.tex"
# therefore:
if ($basename -eq "path") {
   Add-Content $mainfilename "\usepackage{mnsymbol}"
  }
Add-Content $mainfilename "\input{", $dochomeunixstyle, "/latex/ermacros}`n" -NoNewLine
Add-Content $mainfilename "\input{", $erhomeunixstyle , "/latex/erdiagram}`n" -NoNewLine
Add-Content $mainfilename "\input{", $dochomeunixstyle, "/latex/syntaxmacros}`n" -NoNewLine
Add-Content $mainfilename "\begin{document}"
Add-Content $mainfilename "  \begin{preview}"
Add-Content $mainfilename "    \input{", $imagesourcepath, "/" ,$basename, "}`n" -NoNewLine
Add-Content $mainfilename "  \end{preview}"
Add-Content $mainfilename "\end{document}"
