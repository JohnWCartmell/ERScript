
if not exist latex\temp mkdir latex\temp
latex -output-directory=latex\temp latex\catalogue.tex
dvips -P pdf -o latex\temp\catalogue.ps latex\temp\catalogue.dvi
ps2pdf latex\temp\catalogue.ps catalogue.pdf




