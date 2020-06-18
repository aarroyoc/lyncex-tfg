:- module(form, [form_controller/4]).

:- use_module(library(semweb/rdfs)).
:- use_module(library(semweb/rdf11)).

:- use_module(library(pcre)).

:- use_module(library(st/st_render)).

:- use_module('../parameters.pl').
:- use_module('../query.pl').
:- use_module('../handler.pl').

% Delete data
form_controller(Path, get, _Request, FormData) :-
    rdfs_individual_of(Controller, lyncex:'FormController'),
    rdf(Controller, lyncex:url, Path^^xsd:string),
    member('_id'=Resource, FormData),
    member('_delete'=yes, FormData),
    rdf_retractall(Resource, _, _),
    format('Content-Type: text/html~n~n'),
    format('OK').

% Show form (edit)
form_controller(Path, get, _Request, FormData) :-
    rdfs_individual_of(Controller, lyncex:'FormController'),
    rdf(Controller, lyncex:url, Path^^xsd:string),
    rdf(Controller, lyncex:class, Class),
    member('_id'=Resource, FormData),
    with_output_to(atom(Form),(
        format('<form action="/~w" method="POST">', [Path]),
        format('<input readonly type="url" name="_id" value="~w">', [Resource]),
        forall(rdfs_class_property(Class, Property),(
            (rdf(Property, rdfs:label, Placeholder^^xsd:string);Placeholder=Property),
            (
                rdf(Property, lyncex:multiple, true)
            ->
                findall(ValueProperty, rdf_literal_or_iri(Resource, Property, ValueProperty), ValueProperties),
                reverse(ValueProperties, ReverseValueProperties),
                foldl(string_concat_newline, ReverseValueProperties, "", OutValueProperties),
                format('<textarea placeholder="~w" name="~w">~w</textarea>', [Placeholder, Property, OutValueProperties])
            ;
                rdf_literal_or_iri(Resource, Property, ValueProperty)
                ->
                format('<input type="text" placeholder="~w" name="~w" value="~w">', [Placeholder, Property, ValueProperty])
                ;
                format('<input type="text" placeholder="~w" name="~w">', [Placeholder, Property])
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
    process_parameters(FormData, Controller, Parameters),
    % Queries and Handlers
    resolve_query(Controller, Parameters, XQuery),
    resolve_handler(Controller, Parameters, XHandler),
    flatten([XQuery, XHandler, 'form'-Form], XOutput),
    dict_pairs(TemplateData, _, XOutput),
    format('Content-Type: text/html~n~n'),
    current_output(Output),
    st_render_string(TemplateString, TemplateData, Output, '/dev/null', _{frontend: semblance}).


% Show form (empty)
form_controller(Path, get, _Request, FormData) :-
    rdfs_individual_of(Controller, lyncex:'FormController'),
    rdf(Controller, lyncex:url, Path^^xsd:string),
    rdf(Controller, lyncex:class, Class),
    rdf(Controller, lyncex:base_subject, BaseSubject^^xsd:string),
    % Build form
    with_output_to(atom(Form),(
        format('<form method="POST">'),
        format('<input type="url" name="_id" value="~w">', [BaseSubject]),
        forall(rdfs_class_property(Class, Property),(
            (rdf(Property, rdfs:label, Placeholder^^xsd:string);Placeholder=Property),
            (
                rdf(Property, lyncex:multiple, true)
            ->
                format('<textarea placeholder="~w" name="~w"></textarea>', [Placeholder, Property])
            ;
                format('<input type="text" placeholder="~w" name="~w">', [Placeholder, Property])
            )
        )),
        format('<input type="submit">'),
        format('</form>')
    )),
    % Read template
    rdf(Controller, lyncex:template, Template),
    rdfs_individual_of(Template, cnt:'ContentAsText'),
    rdf(Template, cnt:chars, TemplateString^^xsd:string),
    process_parameters(FormData, Controller, Parameters),
    % Queries and Handlers
    resolve_query(Controller, Parameters, XQuery),
    resolve_handler(Controller, Parameters, XHandler),
    flatten([XQuery, XHandler, 'form'-Form], XOutput),
    dict_pairs(TemplateData, _, XOutput),
    format('Content-Type: text/html~n~n'),
    current_output(Output),
    st_render_string(TemplateString, TemplateData, Output, '/dev/null', _{frontend: semblance}).

% Save data
form_controller(Path, post, _Request, FormData) :-
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
            atom_string(DataValue, AtomDataValue),
            [AtomDataValue] = Values
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
            save_rdf(Resource, DataKey, Value)
        ))
    )),
    format('Content-Type: text/html~n~n'),
    format('OK').

string_concat_newline(S1, S2, S3) :-
    string_concat(S1, "\r\n", S4),
    string_concat(S4, S2, S3).

save_rdf(Resource, DataKey, Value) :-
    number_string(NumberValue, Value),
    rdf_assert(Resource, DataKey, NumberValue).

save_rdf(Resource, DataKey, Value) :-
    string_concat("http", _, Value),
    atom_string(AtomValue, Value),
    rdf_assert(Resource, DataKey, AtomValue).

save_rdf(Resource, DataKey, Value) :-
    rdf_assert(Resource, DataKey, Value^^xsd:string).

:- begin_tests(form_controller).

test(string_concat_newline) :-
    X = "Zutanito", Y = "Menganito",
    string_concat_newline(X, Y, Z),
    Z = "Zutanito\r\nMenganito".

test(save_rdf_number) :-
    X = 'http://example.com/Example', Y = 'age',
    once(save_rdf(X, Y, "256")),
    rdf(X, Y, 256^^xsd:integer).

test(save_rdf_iri) :-
    X = 'http://example.com/Example', Y = 'friend',
    once(save_rdf(X, Y, "http://example.com/Margaret")),
    rdf(X, Y, 'http://example.com/Margaret').

test(save_rdf_string) :-
    X = 'http://example.com/Example', Y = 'name',
    once(save_rdf(X, Y, "Máximo Toño")),
    rdf(X, Y, "Máximo Toño"^^xsd:string).

:- end_tests(form_controller).