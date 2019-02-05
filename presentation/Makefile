all: presentation.pdf

presentation.pdf: presentation.tex include/*.tex ../pictures/*
	 pdflatex presentation.tex presentation.pdf

clean:  
	rm -f *.aux *.out *.toc *.nav *.snm *.log *.pdf *.fls *.fdb*
