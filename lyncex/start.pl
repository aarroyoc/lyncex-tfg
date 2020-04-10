:- set_test_options([load(never)]).
:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_header)).
:- use_module(library(http/http_unix_daemon)).
:- use_module(library(http/html_write)).

:- use_module('main.pl').

:- run.