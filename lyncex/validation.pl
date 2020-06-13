:- module(validation, [valid/0]).

:- use_module(library(semweb/rdf11)).
:- use_module(library(semweb/rdfs)).

:- use_module('prefix.pl').

% Validates that a propetry from a class defining a 
% rdfs:range its linked correctly with a target of an acceptable class
% Also checks rdfs:domain

valid :-
    \+ getenv('LYNCEX_RDF_SCHEMA_VALIDATION', false)
    ->
    (
        rdf_assert('http://www.w3.org/2001/XMLSchema#string', rdfs:subClassOf, 'http://www.w3.org/2000/01/rdf-schema#Literal'),
        forall(rdf(X, Y, Z),(
            % CHECK DOMAIN
            (
                rdf(Y, rdfs:domain, Domain)
            ->
                rdfs_individual_of(X, Domain)
            ;
                true
            ),
            % CHECK RANGE
            (
                rdf(Y, rdfs:range, Range)
            ->
                rdfs_individual_of(Z, Range)
            ;
                true
            )
        )),
        rdf_retractall('http://www.w3.org/2001/XMLSchema#string', rdfs:subClassOf, 'http://www.w3.org/2000/01/rdf-schema#Literal')
    )
    ;
    true.

:- begin_tests(validation).

test(valid_range) :-
    rdf_retractall(_,_,_),
    % ONTOLOGY
    Class = 'http://example.com/Class',
    Property = 'http://example.com/property',
    Class2 = 'http://example.com/Class2',
    rdf_assert(Class, rdf:type, rdfs:'Class'),
    rdf_assert(Property, rdf:type, rdf:'Property'),
    rdf_assert(Property, rdfs:domain, Class),
    rdf_assert(Property, rdfs:range, Class2),
    % DATA
    rdf_assert('http://example.com/Subject', rdf:type, Class),
    rdf_assert('http://example.com/Subject', Property, 'http://example.com/Subject2'),
    rdf_assert('http://example.com/Subject2', rdf:type, Class2),
    valid_range,
    rdf_retractall(_,_,_).

test(valid_range_fail) :-
    rdf_retractall(_,_,_),
    % ONTOLOGY
    Class = 'http://example.com/Class',
    Property = 'http://example.com/property',
    Class2 = 'http://example.com/Class2',
    rdf_assert(Class, rdf:type, rdfs:'Class'),
    rdf_assert(Property, rdf:type, rdf:'Property'),
    rdf_assert(Property, rdfs:domain, Class),
    rdf_assert(Property, rdfs:range, Class2),
    % DATA
    rdf_assert('http://example.com/Subject', rdf:type, Class),
    rdf_assert('http://example.com/Subject', Property, 'http://example.com/Subject2'),
    rdf_assert('http://example.com/Subject2', rdf:type, Class),
    \+ valid_range,
    rdf_retractall(_,_,_).

test(valid_range_literal) :-
    rdf_retractall(_,_,_),
    % ONTOLOGY
    Class = 'http://example.com/Class',
    Property = 'http://example.com/property',
    rdf_assert(Class, rdf:type, rdfs:'Class'),
    rdf_assert(Property, rdf:type, rdf:'Property'),
    rdf_assert(Property, rdfs:domain, Class),
    rdf_assert(Property, rdfs:range, xsd:string),
    % DATA
    rdf_assert('http://example.com/Subject', rdf:type, Class),
    rdf_assert('http://example.com/Subject', Property, "Máximo"),
    valid_range,
    rdf_retractall(_,_,_).

test(valid_range_literal_fail) :-
    rdf_retractall(_,_,_),
    % ONTOLOGY
    Class = 'http://example.com/Class',
    Property = 'http://example.com/property',
    Class2 = 'http://example.com/Class2',
    rdf_assert(Class, rdf:type, rdfs:'Class'),
    rdf_assert(Property, rdf:type, rdf:'Property'),
    rdf_assert(Property, rdfs:domain, Class),
    rdf_assert(Property, rdfs:range, Class2),
    % DATA
    rdf_assert('http://example.com/Subject', rdf:type, Class),
    rdf_assert('http://example.com/Subject', Property, "Máximo"),
    \+ valid_range,
    rdf_retractall(_,_,_).


:- end_tests(validation).