:- module(parameters, [process_parameters/3]).

:- use_module(library(semweb/rdfs)).
:- use_module(library(semweb/rdf11)).

:- use_module(library(pcre)).

:- dynamic validation/1.

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

:- begin_tests(parameters).

test(process_parameters_empty) :-
    Controller = 'http://example.com/Controller',
    Parameter = 'http://example.com/ControllerParameter',
    ParamName = "id",
    rdf_assert(Controller, lyncex:parameter, Parameter),
    rdf_assert(Parameter, lyncex:param_name, ParamName),
    FormData = [id="42"],
    process_parameters(FormData, Controller, OutDict),
    OutDict = _{id:"42"}.

test(process_parameters_regex_fail) :-
    Controller = 'http://example.com/Controller',
    Parameter = 'http://example.com/ControllerParameter',
    ParamName = "id",
    rdf_assert(Controller, lyncex:parameter, Parameter),
    rdf_assert(Parameter, lyncex:param_name, ParamName),
    rdf_assert(Parameter, lyncex:validation, "[A-Za-z]"),
    FormData = [id="42"],
    process_parameters(FormData, Controller, _{}).

test(process_parameters_code_fail) :-
    Controller = 'http://example.com/Controller',
    Parameter = 'http://example.com/ControllerParameter',
    ParamName = "id",
    rdf_assert(Controller, lyncex:parameter, Parameter),
    rdf_assert(Parameter, lyncex:param_name, ParamName),
    rdf_assert(Parameter, lyncex:code, "validation(Id) :- fail."),
    FormData = [id="42"],
    process_parameters(FormData, Controller, _{}).

:- end_tests(parameters).