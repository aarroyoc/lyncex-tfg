:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_header)).
:- use_module(library(http/http_unix_daemon)).
:- use_module(library(http/html_write)).
:- use_module(library(semweb/rdfs)).
:- use_module(library(semweb/rdf11)).

:- use_module('api.pl').
:- use_module('prefix.pl').
:- use_module('errorpage.pl').

:- http_handler(root(Path), index(Path, Method), [method(Method)]).

% TextController
index(Path, Method, Request) :-
    rdfs_individual_of(Controller, lyncex:'TextController'),
    rdf(Controller, lyncex:url, Path^^xsd:string),
    rdf(Controller, lyncex:method, ControllerMethod^^xsd:string),
    atom_string(Method, ControllerMethod),
    rdf(Controller, lyncex:content, Content^^xsd:string),
    rdf(Controller, lyncex:mime, ContentMIME^^xsd:string),
    format('Content-Type: '),format(ContentMIME),format('~n~n'),
    format(Content).

index(_Path, _Method, Request) :-
    http_404([], Request).

run :-
    http_daemon([port(11011),fork(false)]).

:- run.