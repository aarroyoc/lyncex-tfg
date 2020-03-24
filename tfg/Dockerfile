FROM debian:buster

RUN apt update && apt install --no-install-recommends -y \
    plantuml make texlive-xetex texlive-lang-spanish texlive-fonts-recommended \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/tfg
