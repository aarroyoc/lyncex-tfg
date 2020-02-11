:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_unix_daemon)).

:- use_module('api.pl').

:- http_handler(root(.), index, [method(get)]).


index(_Request) :-
    format('Content-Type: text/html~n~n'),
    format('OK').

run :-
    http_daemon([port(11011),fork(false)]).

:- run.