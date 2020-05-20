:- module(form, [form_controller/3]).

:- use_module(library(semweb/rdfs)).
:- use_module(library(semweb/rdf11)).
:- use_module(library(http/http_parameters)).

:- use_module(library(pcre)).

:- use_module(library(st/st_render)).

:- use_module('../query.pl').
:- use_module('../handler.pl').


form_controller(Path, get, Request) :-
    rdfs_individual_of(Controller, lyncex:'FormController'),
    rdf(Controller, lyncex:url, Path^^xsd:string),
    rdf(Controller, lyncex:class, Class),
    rdf(Controller, lyncex:base_subject, BaseSubject^^xsd:string),
    % Build form
    with_output_to(atom(Form),(
        format('<form method="POST">'),
        format('<input type="url" name="_id" value="~w">', [BaseSubject]),
        forall((rdfs_class_property(Class, Property)),(
            (
                rdf(Property, lyncex:multiple, true)
            ->
                format('<textarea placeholder="~w" name="~w"></textarea>', [Property, Property])
            ;
                format('<input type="text" placeholder="~w" name="~w">', [Property, Property])
            )
        )),
        format('<input type="submit">'),
        format('</form>')
    )),
    % Read template
    rdf(Controller, lyncex:template, Template),
    rdfs_individual_of(Template, cnt:'ContentAsText'),
    rdf(Template, cnt:chars, TemplateString^^xsd:string),
    % Parameters
    %http_parameters(Request, [], [form_data(FormData)]),
    %process_parameters(FormData, Controller, Parameters),
    Parameters = _{},
    % Queries and Handlers
    resolve_query(Controller, Parameters, XQuery),
    resolve_handler(Controller, Parameters, XHandler),
    flatten([XQuery, XHandler, 'form'-Form], XOutput),
    dict_pairs(TemplateData, _, XOutput),
    format('Content-Type: text/html~n~n'),
    current_output(Output),
    st_render_string(TemplateString, TemplateData, Output, '/dev/null', _{frontend: semblance}).


form_controller(Path, post, Request) :-
    rdfs_individual_of(Controller, lyncex:'FormController'),
    rdf(Controller, lyncex:url, Path^^xsd:string),
    rdf(Controller, lyncex:class, Class),
    http_parameters(Request, [], [form_data(FormData)]),
    member('_id'=Resource, FormData),
    rdf_assert(Resource, rdf:type, Class),
    forall((
        member(DataKey=DataValue, FormData), DataKey \= '_id'
    ),(
        rdfs_class_property(Class, DataKey),
        (
            rdf(DataKey, lyncex:validation, Validation^^xsd:string)
            ->
            re_match(Validation, DataValue)
            ;
            true
        ),
        (
            rdf(DataKey, lyncex:code_validation, ValidationCode^^xsd:string)
            ->
            atom_string(ValidationAtom, ValidationCode),
            read_term_from_atom(ValidationAtom, ValidationTerm, []),
            retractall(validation(_)),
            assertz(ValidationTerm),
            once(call(validation, DataValue))
            ;
            true
        )
    )),
    forall((
        member(DataKey=DataValue, FormData), DataKey \= '_id'
        ), (
        rdf_assert(Resource, DataKey, DataValue^^xsd:string)
    )),
    form_controller(Path, get, Request).