all: tfg.pdf 

tfg.pdf: lyncex.png
	xelatex tfg
	bibtex tfg
	xelatex tfg
	xelatex tfg

lyncex.png:
	plantuml lyncex.txt

clean:
	rm tfg.pdf
	rm tfg.aux
	rm tfg.log
	rm tfg.out
	rm tfg.bbl
	rm tfg.blg
	rm lyncex.png