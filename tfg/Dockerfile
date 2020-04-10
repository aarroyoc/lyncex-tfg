FROM debian:buster

RUN apt update && apt install --no-install-recommends -y \
    make texlive-xetex texlive-lang-spanish texlive-fonts-recommended \
    python3.7 python3-rdflib git graphviz ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN git clone http://github.com/usc-isi-i2/ontology-visualization /opt/ontology-visualization

WORKDIR /opt/tfg
