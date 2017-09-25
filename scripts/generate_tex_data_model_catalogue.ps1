

$texhead = Get-Content ..\ERmodel_v1.4\latex\texhead.txt

Set-Content latex\catalogue.tex $texhead

Add-Content latex\catalogue.tex "\author{ John Cartmell}`n"
Add-Content latex\catalogue.tex "\title{Data Models Catalogue}`n"
Add-Content latex\catalogue.tex "\begin{document}`n"
Add-Content latex\catalogue.tex "\maketitle`n"
Add-Content latex\catalogue.tex "\tableofcontents`n"

Get-ChildItem "src"  -Filter *.xml | `
 Foreach-Object{    
    $content = Get-Content $_.FullName
    $modelname = $_.BaseName 
    Add-Content latex\catalogue.tex "\section{" , $modelname , "}`n" -NoNewline
    Add-Content latex\catalogue.tex "\subsection{Logical}`n" -NoNewline
    Add-Content latex\catalogue.tex "\input{", $modelname , ".tex}`n" -NoNewLine
    Add-Content latex\catalogue.tex "\newline`n" -NoNewLine
    Add-Content latex\catalogue.tex "\subsection{Hierarchical}`n" -NoNewline
    Add-Content latex\catalogue.tex "\input{" , $modelname , ".hierarchical.tex}`n" -NoNewLine
    Add-Content latex\catalogue.tex "\newline`n" -NoNewLine
    Add-Content latex\catalogue.tex "\subsection{Relational}`n" -NoNewline
    Add-Content latex\catalogue.tex "\input{" , $modelname , ".relational.tex}`n" -NoNewLine
    Add-Content latex\catalogue.tex "\newline`n" -NoNewLine
}
  
$textail = Get-Content ..\ERmodel_v1.4\latex\textail.txt

Add-Content latex\catalogue.tex $textail
