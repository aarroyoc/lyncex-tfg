:- module(prefix, []).

:- use_module(library(semweb/rdf_db)).

:- rdf_register_prefix(rdf, 'http://www.w3.org/1999/02/22-rdf-syntax-ns#').
:- rdf_register_prefix(rdfs, 'http://www.w3.org/2000/01/rdf-schema#').
:- rdf_register_prefix(xsd, 'http://www.w3.org/2001/XMLSchema#').
:- rdf_register_prefix(cnt, 'http://www.w3.org/2011/content#').
:- rdf_register_prefix(dct, 'http://purl.org/dc/terms/').
:- rdf_register_prefix(lyncex, 'https://lyncex.com/lyncex#').