:- module(api, []).

:- use_module(library(http/http_client)).
:- use_module(library(http/http_parameters)).
:- use_module(library(semweb/turtle)).

:- http_handler(root('_api'), ingest, [method(post)]).
:- http_handler(root('_api/query'), query, [method(get)]).

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

query(Request) :-
    http_parameters(Request, [
        subject(Subject, [optional(true)]),
        predicate(Predicate, [optional(true)]),
        object(Object, [optional(true)])
    ]),
    findall([Subject, Predicate, Object],rdf(Subject,Predicate, Object), Outputs),
    format('Content-Type: text/plain~n~n'),
    forall(member(Output, Outputs),(
        % TODO: Fails with crud.ttl 
        atomic_list_concat(Output,' ', OutLine),
        format(OutLine),
        format('~n')
    )).

