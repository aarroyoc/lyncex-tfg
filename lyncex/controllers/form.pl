:- module(form, [form_controller/3]).

:- use_module(library(semweb/rdfs)).
:- use_module(library(semweb/rdf11)).
:- use_module(library(http/http_parameters)).

:- use_module(library(st/st_render)).


form_controller(Path, get, Request) :-
    rdfs_individual_of(Controller, lyncex:'FormController'),
    rdf(Controller, lyncex:url, Path^^xsd:string),
    rdf(Controller, lyncex:class, Class),
    rdf(Controller, lyncex:base_subject, BaseSubject^^xsd:string),
    % TODO Autogenerate form
    format('Content-Type: text/html~n~n'),
    format('<form method="POST">'),
    format('<input type="url" name="_id" value="~w">', [BaseSubject]),
    forall((rdfs_class_property(Class, Property)),(
        format('<input type="text" placeholder="~w" name="~w">', [Property, Property])
    )),
    format('<input type="submit">'),
    format('</form>').


form_controller(Path, post, Request) :-
    rdfs_individual_of(Controller, lyncex:'FormController'),
    rdf(Controller, lyncex:url, Path^^xsd:string),
    rdf(Controller, lyncex:class, Class),
    http_parameters(Request, [], [form_data(FormData)]),
    member('_id'=Resource, FormData),
    rdf_assert(Resource, rdf:type, Class),
    forall((
        member(DataKey=DataValue, FormData), DataKey \= '_id'
        ), (
        rdf_assert(Resource, DataKey, DataValue^^xsd:string)
    )),
    form_controller(Path, get, Request).