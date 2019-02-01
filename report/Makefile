all: build clean

build: report.tex
	pdflatex report.tex
	bibtex report
	pdflatex report.tex

clean:
	rm -f *.fls *.log *.gz *latexmk *.aux *.toc *.bbl *.blg

help:
	@printf "all:     \tmake the report and clean\n"
	@printf "build:   \tmake the report\n"
	@printf "clean:   \tclean all auxilliary files in root and data\n"
