
if not exist temp mkdir temp
latex -output-directory=temp catalogue.tex
dvips -P pdf -o temp\catalogue.ps temp\catalogue.dvi
ps2pdf temp\catalogue.ps catalogue.pdf




