all: build clean

build: include/*.tex ../pictures/*
	latexmk -pdf presentation.tex
	latexmk -c
clean:  
	rm -f *.aux *.out *.toc *.nav *.snm *.log *.fls *.fdb *.vrb

help:
	@printf "all:     \tmake the presentation and clean\n"
	@printf "build:   \tmake the report\n"
	@printf "clean:   \t clean all the compilable files (except the pdf)"
