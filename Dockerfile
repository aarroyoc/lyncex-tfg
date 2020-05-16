FROM swipl:8.1.30

RUN useradd -m prolog
USER prolog

RUN swipl -t 'pack_install(simple_template,[interactive(false)])'

WORKDIR /opt/lyncex

COPY ./lyncex .

CMD ["/usr/bin/swipl", "start.pl"]
