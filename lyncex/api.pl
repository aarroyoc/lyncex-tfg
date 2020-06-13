:- module(api, []).

:- use_module(library(http/http_client)).
:- use_module(library(http/http_parameters)).
:- use_module(library(semweb/turtle)).
:- use_module(library(semweb/rdf11)).

:- use_module('validation.pl').
:- use_module('setup.pl').

:- http_handler(root('_api'), ingest, [method(post)]).
:- http_handler(root('_api/query'), query, [method(get)]).
:- http_handler(root('_api/delete'), delete, [method(delete)]).

:- dynamic bnode/2.

map_bnode(SOrg, OOrg, S, O) :-
    (   OOrg = node(N1) ->
        (   bnode(N1, B1) ->
            O = B1
        ;   rdf_create_bnode(B1),
            O = B1,
            assertz(bnode(N1, B1))
        )
    ;   O = OOrg
    ),
    (   SOrg = node(N2) ->
        (   bnode(N2, B2) ->
            S = B2
        ;   rdf_create_bnode(B2),
            S = B2,
            assertz(bnode(N2, B2))
        )
    ;   S = SOrg
    ).

ingest(Request) :-
    memberchk(content_type(ContentType), Request),
    atom_concat('text/turtle', _, ContentType),
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
    retractall(bnode(_,_)),
    setup.

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
    %rdf_save_turtle(Response, []).
    rdf_save_turtle(Response, [
        expand(query_filter(Subject, Predicate))
    ]).

delete(Request) :-
    http_parameters(Request, [
        subject(Subject, [optional(true)]),
        predicate(Predicate, [optional(true)]),
        object(Object, [optional(true)])
    ]),
    rdf_retractall(Subject, Predicate, Object),
    format('Content-Type: text/plain~n~n'),
    format('OK').


:- begin_tests(api).

test(bnode) :-
    X = rdf(node(1), lyncex:content, node(2)),
    X = rdf(SOrg, _, OOrg),
    map_bnode(SOrg, OOrg, S, O),
    not(S = node(_)),
    not(O = node(_)).


:- end_tests(api).