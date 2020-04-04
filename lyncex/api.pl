:- module(api, []).

:- use_module(library(http/http_client)).
:- use_module(library(http/http_parameters)).
:- use_module(library(semweb/turtle)).
:- use_module(library(semweb/rdf11)).

:- use_module('validation.pl').

:- http_handler(root('_api'), ingest, [method(post)]).
:- http_handler(root('_api/query'), query, [method(get)]).
:- http_handler(root('_api/delete'), delete, [method(delete)]).

:- dynamic bnode/2.

map_bnode(SOrg, OOrg, S, O) :-
    (   OOrg = node(N) ->
        (   bnode(N, B) ->
            O = B
        ;   rdf_create_bnode(B),
            O = B,
            assertz(bnode(N, B))
        )
    ;   O = OOrg
    ),
    (   SOrg = node(N) ->
        (   bnode(N, B) ->
            S = B
        ;   rdf_create_bnode(B),
            S = B,
            assertz(bnode(N, B))
        )
    ;   S = SOrg
    ).

ingest(Request) :-
    memberchk(content_type('text/turtle'), Request),
    http_read_data(Request, Input, [
        to(atom),
        input_encoding('utf-8')
    ]),
    rdf_read_turtle(atom(Input), Triples, []),
    forall(member(Triple, Triples), (
        Triple = rdf(SOrg, P, OOrg),
        map_bnode(SOrg, OOrg, S, O),
        rdf_assert(S, P, O)
    )),
    (   valid ->
        format('Content-Type: text/html~n~n'),
        format('OK')
    ;
        forall(member(Triple, Triples), (
            Triple = rdf(SOrg, P, OOrg),
            map_bnode(SOrg, OOrg, S, O),
            rdf_retractall(S, P, O)
        )),
        format('Content-Type: text/html~n~n'),
        format('NOT VALID')
    ),
    retractall(bnode(_,_)).


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