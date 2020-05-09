:- module(template, [template_controller/3]).

:- use_module(library(semweb/rdfs)).
:- use_module(library(semweb/rdf11)).
:- use_module(library(http/http_parameters)).

:- use_module(library(st/st_render)).

:- use_module('../parameters.pl').

:- dynamic handler/1.

:- rdf_meta db(r,r,o).

db(S, P, O) :-
    rdf(S, P, O^^_).

template_controller(Path, Method, Request) :-
    rdfs_individual_of(Controller, lyncex:'TemplateController'),
    rdf(Controller, lyncex:url, Path^^xsd:string),
    rdf(Controller, lyncex:method, MethodString^^xsd:string),
    atom_string(Method, MethodString),
    rdf(Controller, lyncex:template, Template),
    rdfs_individual_of(Template, cnt:'ContentAsText'),
    rdf(Template, cnt:chars, TemplateString^^xsd:string),
    % Process parameters
    http_parameters(Request, [], [form_data(FormData)]),
    process_parameters(FormData, Controller, Parameters),
    % Queries and Handlers
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
            rdf(QuerySubject, QueryProperty, QueryValue^^_),
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
    ), XQuery),
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
    ), XHandler),
    flatten([XQuery, XHandler], XOutput),
    dict_pairs(TemplateData, _, XOutput),
    format('Content-Type: text/html~n~n'),
    current_output(Output),
    st_render_string(TemplateString, TemplateData, Output, '/dev/null', _{frontend: semblance}).

template_controller(Path, _Method, _Request) :-
    rdfs_individual_of(Controller, lyncex:'TemplateController'),
    rdf(Controller, lyncex:url, Path^^xsd:string),
    rdf(Controller, lyncex:template, Template),
    rdfs_individual_of(Template, cnt:'ContentAsText'),
    rdf(Template, cnt:chars, TemplateString^^xsd:string),
    format('Content-Type: text/html~n~n'),
    current_output(Output),
    st_render_string(TemplateString, _{ lyncex: 'Lyncex' }, Output, '/dev/null', _{ frontend: semblance}).