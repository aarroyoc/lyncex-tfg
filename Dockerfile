FROM swipl:8.0.3

RUN useradd -m prolog
USER prolog

RUN swipl -t 'pack_install(simple_template,[interactive(false)])'

WORKDIR /opt/lyncex
