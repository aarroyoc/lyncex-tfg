:- module(login, [login_controller/4]).

:- use_module(library(semweb/rdfs)).
:- use_module(library(semweb/rdf11)).
:- use_module(library(http/http_session)).

:- use_module(library(pcre)).

:- use_module(library(st/st_render)).

:- use_module('../parameters.pl').
:- use_module('../query.pl').
:- use_module('../handler.pl').

login_controller(Path, get, Request, FormData) :-
    rdfs_individual_of(Controller, lyncex:'LoginController'),
    rdf(Controller, lyncex:url, Path^^xsd:string),
    % Build form
    (
        http_session_data(user(User))
        ->
        with_output_to(atom(Form),(
            format('<p>Logged in!</p>')
        ))
        ;
        with_output_to(atom(Form),(
            format('<form method="POST">'),
            format('<input type="text" name="user">'),
            format('<input type="password" name="password">'),
            format('<input type="submit" value="Login">'),
            format('</form>')
        ))
    ),
    % Read template
    rdf(Controller, lyncex:template, Template),
    rdfs_individual_of(Template, cnt:'ContentAsText'),
    rdf(Template, cnt:chars, TemplateString^^xsd:string),
    process_parameters(FormData, Controller, Parameters),
    % Queries and Handlers
    resolve_query(Controller, Parameters, XQuery),
    resolve_handler(Controller, Parameters, XHandler),
    flatten([XQuery, XHandler, 'login'-Form], XOutput),
    dict_pairs(TemplateData, _, XOutput),
    format('Content-Type: text/html~n~n'),
    current_output(Output),
    st_render_string(TemplateString, TemplateData, Output, '/dev/null', _{frontend: semblance}).

login_controller(Path, post, Request, FormData) :-
    rdfs_individual_of(Controller, lyncex:'LoginController'),
    rdf(Controller, lyncex:url, Path^^xsd:string),
    member('user'=User, FormData),
    member('password'=Password, FormData),
    rdf(Controller, lyncex:username, User^^xsd:string),
    rdf(Controller, lyncex:password, Password^^xsd:string),
    http_session_assert(user(User)),
    login_controller(Path, get, Request, FormData).

