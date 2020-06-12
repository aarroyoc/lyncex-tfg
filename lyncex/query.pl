:- module(query, [resolve_query/3, rdf_literal_or_iri/3]).

:- use_module(library(semweb/rdfs)).
:- use_module(library(semweb/rdf11)).

:- use_module(library(st/st_render)).


resolve_query(Controller, Parameters, OutQuery) :-
    findall(FinalQuery, (
        rdf(Controller, lyncex:query, Query),
        rdf(Query, lyncex:query_name, QueryName^^xsd:string),
        (
            rdf(Query, lyncex:subject, QuerySubject)
        ->
            true
        ;
            rdf(Query, lyncex:template_subject, TemplateQuerySubject^^xsd:string),
            with_output_to(atom(QuerySubject),(
                current_output(O1),
                st_render_string(TemplateQuerySubject, Parameters, O1, '/dev/null', _{frontend:semblance})
            ))
        ),
        findall(Value, (
            rdf_literal_or_iri(QuerySubject, QueryProperty, QueryValue),
            atom_string(QueryProperty, QueryPropertyString),
            split_string(QueryPropertyString, "/#", "/#", QueryPropertyList),
            length(QueryPropertyList, N),
            nth1(N, QueryPropertyList, SimpleQueryPropertyString),
            atom_string(SimpleQueryProperty, SimpleQueryPropertyString),
            Value=SimpleQueryProperty-QueryValue
        ), XS),
        remove_repeated(XS, DictionaryData),
        dict_pairs(QueryData, _, DictionaryData),
        atom_string(AtomQueryName, QueryName),
        FinalQuery = AtomQueryName-QueryData
    ), OutQuery).

rdf_literal_or_iri(QuerySubject, QueryProperty, QueryValue) :-
    rdf(QuerySubject, QueryProperty, QueryValue^^_).

rdf_literal_or_iri(QuerySubject, QueryProperty, QueryValue) :-
    rdf(QuerySubject, QueryProperty, QueryValue),
    atom(QueryValue).

remove_repeated([],[]).
remove_repeated([H|T], Out) :-
    H = Key-_,
    member(Key-_, T),
    remove_repeated(T,Out).

remove_repeated([H|T], Out) :-
    H = Key-_,
    \+ member(Key-_, T),
    remove_repeated(T,X),
    Out = [H|X].

:- begin_tests(query).

test(remove_repeated_do_nothing) :-
    remove_repeated([a-c, b-c], [a-c, b-c]).

test(remove_repeated_remove) :-
    once(remove_repeated([a-b, a-c, b-c], [a-c, b-c])).

:- end_tests(query).