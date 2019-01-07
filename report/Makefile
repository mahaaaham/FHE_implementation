all: build clean
	
build: rapport.tex
	pdflatex rapport.tex

clean:
	rm -f *.fls *.log *.gz *latexmk *.aux

help:
	@printf "all:     \tmake the report and clean\n"
	@printf "build:   \tmake the report\n"
	@printf "clean:   \tclean all auxilliary files in root and data\n"
