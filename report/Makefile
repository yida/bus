#LATEX=lualatex
LATEX=pdflatex
#LATEX=xelatex

%:
	$(LATEX) $@.tex
	open -a preview $@.pdf


all:
	$(LATEX) report.tex
	open -a preview report.pdf


clean:
	rm -f *.out *.aux *.dvi *.log *.txt
