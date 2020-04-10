all: tfg.pdf 

tfg.pdf: lyncex.png
	xelatex tfg
	bibtex tfg
	xelatex tfg
	xelatex tfg

lyncex.png:
	python3 /opt/ontology-visualization/ontology_viz.py -o lyncex.dot lyncex.ttl
	dot -Tpng -o lyncex.png lyncex.dot

clean:
	rm tfg.pdf
	rm tfg.aux
	rm tfg.log
	rm tfg.out
	rm tfg.bbl
	rm tfg.blg
	rm lyncex.png