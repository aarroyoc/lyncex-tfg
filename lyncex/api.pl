:- module(api, []).

:- use_module(library(http/http_client)).
:- use_module(library(http/http_parameters)).
:- use_module(library(semweb/turtle)).
:- use_module(library(semweb/rdf11)).

:- use_module('validation.pl').

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
    valid,
    format('Content-Type: text/html~n~n'),
    format('OK').

% NEEDS SWI PROLOG 8.1.25 to FULLY WORK
query_filter(S, P, S, P, O, _G) :-
    rdf(S, P, O).

query(Request) :-
    http_parameters(Request, [
        subject(Subject, [optional(true)]),
        predicate(Predicate, [optional(true)]),
        object(_Object, [optional(true)])
    ]),
    current_output(Response),
    format('Content-Type: text/turtle~n~n'),
    rdf_save_turtle(Response, []).
    %rdf_save_turtle(Response, [
    %    expand(query_filter(Subject, Predicate))
    %]).

delete(Request) :-
    http_parameters(Request, [
        subject(Subject, [optional(true)]),
        predicate(Predicate, [optional(true)]),
        object(Object, [optional(true)])
    ]),
    rdf_retractall(Subject, Predicate, Object),
    format('Content-Type: text/plain~n~n'),
    format('OK').