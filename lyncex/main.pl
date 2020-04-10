:- module(main, [run/0]).

:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_header)).
:- use_module(library(http/http_unix_daemon)).
:- use_module(library(http/html_write)).
:- use_module(library(semweb/rdfs)).
:- use_module(library(semweb/rdf11)).

:- use_module(library(http/http_error)).

:- use_module('api.pl').
:- use_module('prefix.pl').
:- use_module('errorpage.pl').

:- http_handler(root(Path), index(Path, Method), [method(Method)]).

% AssetController / Base64
index(Path, Method, Request) :-
    rdfs_individual_of(Controller, lyncex:'ContentController'),
    rdf(Controller, lyncex:url, Path^^xsd:string),
    rdf(Controller, lyncex:content, Content),
    rdf(Controller, lyncex:mime, ContentMIME^^xsd:string),
    rdf(Content, rdf:type, cnt:'ContentAsBase64'),
    rdf(Content, cnt:bytes, BytesBase64^^xsd:string),
    base64(Bytes, BytesBase64),
    string_codes(Bytes, OutBytes),
    throw(http_reply(bytes(ContentMIME, OutBytes))).


% ContentController / Text
index(Path, Method, Request) :-
    rdfs_individual_of(Controller, lyncex:'ContentController'),
    rdf(Controller, lyncex:url, Path^^xsd:string),
    %rdf(Controller, lyncex:method, ControllerMethod^^xsd:string),
    %atom_string(Method, ControllerMethod),
    rdf(Controller, lyncex:content, Content),
    rdfs_individual_of(Content, cnt:'ContentAsText'),
    rdf(Content, cnt:chars, Text^^xsd:string),
    rdf(Controller, lyncex:mime, ContentMIME^^xsd:string),
    format('Content-Type: '),format(ContentMIME),format('~n~n'),
    format(Text).

index(_Path, _Method, Request) :-
    http_404([], Request).

run :-
    http_daemon([port(11011),fork(false)]).