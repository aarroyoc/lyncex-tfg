FROM swipl:8.0.3

RUN useradd prolog
USER prolog

WORKDIR /opt/lyncex