:- module(form, [form_controller/4]).

:- use_module(library(semweb/rdfs)).
:- use_module(library(semweb/rdf11)).

:- use_module(library(pcre)).

:- use_module(library(st/st_render)).

:- use_module('../query.pl').
:- use_module('../handler.pl').

string_concat_newline(S1, S2, S3) :-
    string_concat(S1, "\r\n", S4),
    string_concat(S4, S2, S3).

% Delete data
form_controller(Path, get, Request, FormData) :-
    rdfs_individual_of(Controller, lyncex:'FormController'),
    rdf(Controller, lyncex:url, Path^^xsd:string),
    rdf(Controller, lyncex:class, Class),
    member('_id'=Resource, FormData),
    member('_delete'=yes, FormData),
    rdf_retractall(Resource, _, _),
    format('Content-Type: text/html~n~n'),
    format('OK').

% Show form (edit)
form_controller(Path, get, Request, FormData) :-
    rdfs_individual_of(Controller, lyncex:'FormController'),
    rdf(Controller, lyncex:url, Path^^xsd:string),
    rdf(Controller, lyncex:class, Class),
    member('_id'=Resource, FormData),
    with_output_to(atom(Form),(
        format('<form method="POST">'),
        format('<input disabled type="url" name="_id" value="~w">', [Resource]),
        forall(rdfs_class_property(Class, Property),(
            (
                rdf(Property, lyncex:multiple, true)
            ->
                findall(ValueProperty, rdf(Resource, Property, ValueProperty^^_), ValueProperties),
                reverse(ValueProperties, ReverseValueProperties),
                foldl(string_concat_newline, ReverseValueProperties, "", OutValueProperties),
                format('<textarea placeholder="~w" name="~w">~w</textarea>', [Property, Property, OutValueProperties])
            ;
                rdf(Resource, Property, ValueProperty^^_),
                format('<input type="text" placeholder="~w" name="~w" value="~w">', [Property, Property, ValueProperty])
            )
        )),
        format('<input type="submit">'),
        format('</form>'),
        format('<form method="GET">'),
        format('<input type="hidden" name="_delete" value="yes">'),
        format('<input type="hidden" name="_id" value="~w">', [Resource]),
        format('<input type="submit" value="DELETE">'),
        format('</form>')
    )),
    % Read template
    rdf(Controller, lyncex:template, Template),
    rdfs_individual_of(Template, cnt:'ContentAsText'),
    rdf(Template, cnt:chars, TemplateString^^xsd:string),
    Parameters = _{},
    % Queries and Handlers
    resolve_query(Controller, Parameters, XQuery),
    resolve_handler(Controller, Parameters, XHandler),
    flatten([XQuery, XHandler, 'form'-Form], XOutput),
    dict_pairs(TemplateData, _, XOutput),
    format('Content-Type: text/html~n~n'),
    current_output(Output),
    st_render_string(TemplateString, TemplateData, Output, '/dev/null', _{frontend: semblance}).


% Show form (empty)
form_controller(Path, get, Request, FormData) :-
    rdfs_individual_of(Controller, lyncex:'FormController'),
    rdf(Controller, lyncex:url, Path^^xsd:string),
    rdf(Controller, lyncex:class, Class),
    rdf(Controller, lyncex:base_subject, BaseSubject^^xsd:string),
    % Build form
    with_output_to(atom(Form),(
        format('<form method="POST">'),
        format('<input type="url" name="_id" value="~w">', [BaseSubject]),
        forall(rdfs_class_property(Class, Property),(
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
    Parameters = _{},
    % Queries and Handlers
    resolve_query(Controller, Parameters, XQuery),
    resolve_handler(Controller, Parameters, XHandler),
    flatten([XQuery, XHandler, 'form'-Form], XOutput),
    dict_pairs(TemplateData, _, XOutput),
    format('Content-Type: text/html~n~n'),
    current_output(Output),
    st_render_string(TemplateString, TemplateData, Output, '/dev/null', _{frontend: semblance}).

% Save data
form_controller(Path, post, Request, FormData) :-
    rdfs_individual_of(Controller, lyncex:'FormController'),
    rdf(Controller, lyncex:url, Path^^xsd:string),
    rdf(Controller, lyncex:class, Class),
    member('_id'=Resource, FormData),
    rdf_retractall(Resource, _, _),
    rdf_assert(Resource, rdf:type, Class),
    forall((
        member(DataKey=DataValue, FormData), DataKey \= '_id'
    ),(
        rdfs_class_property(Class, DataKey),
        (
            rdf(DataKey, lyncex:multiple, true)
            ->
            atom_string(DataValue, DataValueString), split_string(DataValueString, "\r\n", "", Values)
            ;
            [DataValue] = Values
        ),
        forall(member(Value, Values),(
            (
                rdf(DataKey, lyncex:validation, Validation^^xsd:string)
                ->
                re_match(Validation, Value)
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
                once(call(validation, Value))
                ;
                true
            ),
            rdf_assert(Resource, DataKey, Value^^xsd:string)
        ))
    )),
    format('Content-Type: text/html~n~n'),
    format('OK').