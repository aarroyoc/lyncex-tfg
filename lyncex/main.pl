:- module(main, [run/0]).

:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_header)).
:- use_module(library(http/http_unix_daemon)).
:- use_module(library(http/html_write)).
:- use_module(library(semweb/rdf11)).

:- use_module(library(http/http_error)).

:- use_module('api.pl').
:- use_module('prefix.pl').
:- use_module('errorpage.pl').

:- use_module('controllers/template.pl').
:- use_module('controllers/content.pl').

:- http_handler(root(Path), controller(Path, Method), [method(Method)]).

controller(P, M, R) :- template_controller(P, M, R).
controller(P, M, R) :- content_controller(P, M, R).

controller(_Path, _Method, Request) :-
    http_404([], Request).

run :-
    http_daemon([port(11011),fork(false)]).