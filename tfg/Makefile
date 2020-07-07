all: tfg.pdf 

tfg.pdf: lyncex-2.png plantuml/*.png
	xelatex tfg
	bibtex tfg
	xelatex tfg
	xelatex tfg

lyncex-2.png:
	python3 /opt/ontology-visualization/ontology_viz.py -o lyncex.dot lyncex.ttl
	dot -Tpng -o lyncex-2.png lyncex.dot

clean:
	rm plantuml/*.png
	rm tfg.pdf
	rm tfg.aux
	rm tfg.log
	rm tfg.out
	rm tfg.bbl
	rm tfg.blg
	rm lyncex-2.png

plantuml/*.png:
	cd plantuml; plantuml -charset UTF-8 *.txt