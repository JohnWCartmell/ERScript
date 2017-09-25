
if not exist latex\temp mkdir latex\temp
cd latex
latex -output-directory=temp catalogue.tex
dvips -P pdf -o temp\catalogue.ps temp\catalogue.dvi
cd ..
ps2pdf latex\temp\catalogue.ps catalogue.pdf




