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
            put_dict(SimpleQueryProperty, _{lyncex: 'Lyncex'}, QueryValue, Value)
        ), XS),
        dicts_join(lyncex, XS, QueryDataL),
        nth1(1, QueryDataL, QueryData),
        atom_string(AtomQueryName, QueryName),
        FinalQuery = AtomQueryName-QueryData
    ), OutQuery).

rdf_literal_or_iri(QuerySubject, QueryProperty, QueryValue) :-
    rdf(QuerySubject, QueryProperty, QueryValue^^_).

rdf_literal_or_iri(QuerySubject, QueryProperty, QueryValue) :-
    rdf(QuerySubject, QueryProperty, QueryValue),
    atom(QueryValue).