:- module(template, [template_controller/4]).

:- use_module(library(semweb/rdfs)).
:- use_module(library(semweb/rdf11)).
:- use_module(library(http/http_parameters)).

:- use_module(library(st/st_render)).

:- use_module('../parameters.pl').
:- use_module('../query.pl').
:- use_module('../handler.pl').

template_controller(Path, Method, Request, FormData) :-
    rdfs_individual_of(Controller, lyncex:'TemplateController'),
    rdf(Controller, lyncex:url, Path^^xsd:string),
    rdf(Controller, lyncex:method, MethodString^^xsd:string),
    atom_string(Method, MethodString),
    rdf(Controller, lyncex:template, Template),
    rdfs_individual_of(Template, cnt:'ContentAsText'),
    rdf(Template, cnt:chars, TemplateString^^xsd:string),
    % Process parameters
    process_parameters(FormData, Controller, Parameters),
    % Queries and Handlers
    resolve_query(Controller, Parameters, XQuery),
    resolve_handler(Controller, Parameters, XHandler),
    flatten([XQuery, XHandler], XOutput),
    dict_pairs(TemplateData, _, XOutput),
    format('Content-Type: text/html~n~n'),
    current_output(Output),
    st_render_string(TemplateString, TemplateData, Output, '/dev/null', _{frontend: semblance}).

template_controller(Path, _Method, _Request, _FormData) :-
    rdfs_individual_of(Controller, lyncex:'TemplateController'),
    rdf(Controller, lyncex:url, Path^^xsd:string),
    rdf(Controller, lyncex:template, Template),
    rdfs_individual_of(Template, cnt:'ContentAsText'),
    rdf(Template, cnt:chars, TemplateString^^xsd:string),
    format('Content-Type: text/html~n~n'),
    current_output(Output),
    st_render_string(TemplateString, _{ lyncex: 'Lyncex' }, Output, '/dev/null', _{ frontend: semblance}).