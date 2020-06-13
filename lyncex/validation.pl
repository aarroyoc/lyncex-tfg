:- module(validation, [valid/0]).

:- use_module(library(semweb/rdf11)).
:- use_module(library(semweb/rdfs)).

:- use_module('prefix.pl').

% Validation before accepting a file

valid :- valid_range.

% Validates that a propetry from a class defining a 
% rdfs:range it's linked correctly with a target of an acceptable class
valid_range :-
    forall(rdf(Class, rdf:type, rdfs:'Class'),(
        forall(rdfs_individual_of(Resource, Class),(
            forall(rdfs_class_property(Class, Property),(
                forall(rdf(Property, rdfs:range, RangeClass),(
                    forall(rdf(Resource, Property, RangeResource),(
                        rdfs_individual_of(RangeResource, RangeClass2),
                        rdfs_subclass_of(RangeClass2, RangeClass)
                    ))
                ))
            ))
        ))
    )).