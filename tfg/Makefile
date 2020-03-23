all: tfg.pdf

tfg.pdf:
	xelatex tfg
	bibtex tfg
	xelatex tfg
	xelatex tfg

clean:
	rm tfg.pdf
	rm tfg.aux
	rm tfg.log
	rm tfg.out
	rm tfg.bbl
	rm tfg.blg
	rm tfg.dvi