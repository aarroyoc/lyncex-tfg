:- module(handler, [resolve_handler/3]).

:- use_module(library(semweb/rdfs)).
:- use_module(library(semweb/rdf11)).

:- dynamic handler/2.

:- rdf_meta db(r,r,o).

db(S, P, O) :-
    rdf(S, P, O^^_).


resolve_handler(Controller, Parameters, OutHandler) :-
    findall(DictHandler, (
        rdf(Controller, lyncex:handler, Handler),
        rdf(Handler, lyncex:handler_name, HandlerName^^xsd:string),
        atom_string(HandlerAtomName, HandlerName),
        rdf(Handler, lyncex:code, HandlerCode^^xsd:string),
        atom_string(HandlerAtom, HandlerCode),
        read_term_from_atom(HandlerAtom, HandlerTerm, []),
        retractall(handler(_,_)),
        assertz(HandlerTerm),
        once(call(handler, Parameters, OutputHandler)),
        DictHandler = HandlerAtomName-OutputHandler
    ), OutHandler).

:- begin_tests(handler).

test(db) :-
    X = 'http://example.com/Example', Y = 'name',
    rdf_assert(X, Y, "Máximo Toño"),
    db(X, Y, "Máximo Toño").

test(resolve_handler) :-
    Controller = 'http://example.com/Controller',
    Parameters = _{a:42, b:37},
    Handler = 'http://example.com/ControllerHandler',
    HandlerName = "sum",
    HandlerCode = "handler(Param, Output) :- get_dict(a, Param, A), get_dict(b, Param, B), Output is A+B.",
    rdf_assert(Controller, lyncex:handler, Handler),
    rdf_assert(Handler, lyncex:handler_name, HandlerName),
    rdf_assert(Handler, lyncex:code, HandlerCode),
    resolve_handler(Controller, Parameters, OutHandler),
    OutHandler = [sum-79].

:- end_tests(handler).
