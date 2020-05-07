:- module(parameters, [process_parameters/3]).

:- use_module(library(semweb/rdfs)).
:- use_module(library(semweb/rdf11)).

:- use_module(library(pcre)).

process_parameters(FormData, Controller, ParamDict) :-
    findall(Pair, (
        rdf(Controller, lyncex:parameter, Parameter),
        rdf(Parameter, lyncex:param_name, ParameterName^^xsd:string),
        atom_string(AtomParameterName, ParameterName),
        member(AtomParameterName=ParameterValue, FormData),
        (   
            rdf(Parameter, lyncex:validation, Validation^^xsd:string)
            ->
            re_match(Validation, ParameterValue)
            ;
            true
        ),
        (
            rdf(Parameter, lyncex:code, ValidationCode^^xsd:string)
            ->
            atom_string(ValidationAtom, ValidationCode),
            read_term_from_atom(ValidationAtom, ValidationTerm, []),
            retractall(validation(_)),
            assertz(ValidationTerm),
            once(call(validation, ParameterValue))
            ;
            true
        ),
        Pair = AtomParameterName-ParameterValue
    ), ListPair),
    dict_pairs(ParamDict, _, ListPair).