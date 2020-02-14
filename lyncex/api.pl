:- module(api, []).

:- use_module(library(http/http_client)).
:- use_module(library(http/http_parameters)).
:- use_module(library(semweb/turtle)).
:- use_module(library(semweb/rdf11)).

:- http_handler(root('_api'), ingest, [method(post)]).
:- http_handler(root('_api/query'), query, [method(get)]).
:- http_handler(root('_api/delete'), delete, [method(delete)]).

ingest(Request) :-
    memberchk(content_type('text/turtle'), Request),
    http_read_data(Request, Input, [
        to(atom),
        input_encoding('utf-8')
    ]),
    rdf_read_turtle(atom(Input), Triples, []),
    forall(member(Triple, Triples), (
        Triple = rdf(S, P, O),
        rdf_assert(S, P, O)
    )),
    format('Content-Type: text/html~n~n'),
    format('OK').

query(Request) :-
    http_parameters(Request, [
        subject(Subject, [optional(true)]),
        predicate(Predicate, [optional(true)]),
        object(Object, [optional(true)])
    ]),
    % FILTERING DOESNT WORK
    findall([Subject, Predicate, Object],rdf(Subject,Predicate, Object), Outputs),
    format('Content-Type: text/plain~n~n'),
    forall(member(Output, Outputs),(
        forall(member(Field, Output), (
            (
                ^^(Literal, _) = Field,
                format(Literal)
            );format(Field)
            ,
            format(' ')
        )),
        format('~n')
    )).

delete(Request) :-
    http_parameters(Request, [
        subject(Subject, [optional(true)]),
        predicate(Predicate, [optional(true)]),
        object(Object, [optional(true)])
    ]),
    rdf_retractall(Subject, Predicate, Object),
    format('Content-Type: text/plain~n~n'),
    format('OK').