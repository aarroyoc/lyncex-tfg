:- module(api, []).

:- use_module(library(http/http_client)).
:- use_module(library(semweb/turtle)).

:- http_handler(root('_api'), ingest, [method(post)]).
%:- http_handler(root('_api/query'), query, [method(post)]).

ingest(Request) :-
    memberchk(content_type('text/turtle'), Request),
    http_read_data(Request, Input, [
        to(atom),
        input_encoding('utf-8')
    ]),
    rdf_read_turtle(atom(Input), Triples, []),
    forall(member(Triple, Triples), assertz(Triple)),
    format('Content-Type: text/html~n~n'),
    format('OK').

%query(Request) :-
%    memberchk(content_type('application/x-prolog'), Request),
%    http_read_data(Request, Input, [
%        to(atom),
%        input_encoding('utf-8')
%    ]),
%    term_to_atom(Code,Input),
%    findall(A, Code, Out),
%    format('Content-Type: text/html~n~n'),
%    format(Out).
