all: presentation.pdf clean

presentation.pdf: presentation.tex include/*.tex ../pictures/*
	latexmk -pdf presentation.tex
	latexmk -c
clean:  
	rm -f *.aux *.out *.toc *.nav *.snm *.log *.fls *.fdb*

help:
	@printf "all:     \tmake the presentation and clean\n"
	@printf "build:   \tmake the report\n"
	@printf "clean:   \t clean all the compilable files (not the pdf)"
