
$commandFolder=Split-Path $MyInvocation.MyCommand.Path

. ($commandFolder +'\set_path_variables.ps1')

$texhead = Get-Content $ERHOME\latex\texhead.txt

Set-Content latex\catalogue.tex $texhead

Add-Content latex\catalogue.tex "\author{ John Cartmell}`n"
Add-Content latex\catalogue.tex "\title{Concept Models Catalogue}`n"
Add-Content latex\catalogue.tex "\begin{document}`n"
Add-Content latex\catalogue.tex "\maketitle`n"
Add-Content latex\catalogue.tex "\tableofcontents`n"

Get-ChildItem "src"  -Filter *.xml | `
 Foreach-Object{    
    $content = Get-Content $_.FullName
    $modelname = $_.BaseName 
 
    
    Add-Content latex\catalogue.tex "\section{" , $modelname , "}`n" -NoNewline
    Add-Content latex\catalogue.tex "\input{", $modelname , ".tex}`n" -NoNewLine
    Add-Content latex\catalogue.tex "\newline`n" -NoNewLine
}
  
$textail = Get-Content $ERHOME\latex\textail.txt

Add-Content latex\catalogue.tex $textail
