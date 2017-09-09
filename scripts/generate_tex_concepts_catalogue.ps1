

$texhead = Get-Content ..\ERmodel_v1.3\latex\texhead.txt

Set-Content catalogue.tex $texhead

Add-Content catalogue.tex "\author{ John Cartmell}`n"
Add-Content catalogue.tex "\title{Concept Models Catalogue}`n"
Add-Content catalogue.tex "\begin{document}`n"
Add-Content catalogue.tex "\maketitle`n"
Add-Content catalogue.tex "\tableofcontents`n"

Get-ChildItem "src"  -Filter *.xml | `
 Foreach-Object{    
    $content = Get-Content $_.FullName
    $modelname = $_.BaseName 
 
    
    Add-Content catalogue.tex "\section{" , $modelname , "}`n" -NoNewline
    Add-Content catalogue.tex "\input{latex/" , $modelname , ".tex}`n" -NoNewLine
    Add-Content catalogue.tex "\newline`n" -NoNewLine
}
  
$textail = Get-Content ..\ERmodel_v1.3\latex\textail.txt

Add-Content catalogue.tex $textail
