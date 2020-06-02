FROM swipl:8.2.0

RUN useradd -m prolog
USER prolog

RUN swipl -t 'pack_install(simple_template,[interactive(false)])'

WORKDIR /opt/lyncex

COPY ./lyncex .

CMD ["/usr/bin/swipl", "start.pl"]
