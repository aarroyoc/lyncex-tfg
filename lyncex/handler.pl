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
