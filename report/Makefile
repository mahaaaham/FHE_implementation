all: build clean move

build: report.tex
	latexmk -pdf report.tex
	latexmk -c

clean:
	rm -f *.fls *.log *.gz *latexmk *.aux *.toc *.bbl *.blg

move:
	mv report.pdf ../

help:
	@printf "all:     \tmake the report and clean\n"
	@printf "build:   \tmake the report\n"
	@printf "move:	  \tmove the report in root of the git folder\n"
	@printf "clean:   \tclean all auxilliary files in root and data\n"
