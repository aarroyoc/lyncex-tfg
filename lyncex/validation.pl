:- module(validation, [valid/0]).

:- use_module(library(semweb/rdf11)).
:- use_module(library(semweb/rdfs)).

:- use_module('prefix.pl').

valid :- valid_range, valid_domain.

valid_range :-
    forall(rdf(Class, rdf:type, rdfs:'Class'),(
        forall(rdfs_individual_of(Resource, Class),(
            forall(rdfs_class_property(Class, Property),(
                forall(rdf(Property, rdfs:range, RangeClass),(
                    forall(rdf(Resource, Property, RangeResource),(
                        rdfs_individual_of(RangeResource, RangeClass2),
                        rdfs_subclass_of(RangeClass2, RangeClass)
                        %forall(rdf(RangeResource, rdf:type, RangeClass2),(
                        %    rdfs_subclass_of(RangeClass2, RangeClass)
                        %))
                    ))
                ))
            ))
        ))
    )).
    % rdfs_individual_of(Resource, Class)
    %rdfs_class_property(Class, Property),
    %rdf(Property, rdfs:range, RangeClass),
    %rdf(Resource, Property, RangeResource),
    %rdf(RangeResource, rdf:type, RangeClass2)
    %rdfs_subclass_of(RangeClass2, RangeClass).

valid_domain :-
    forall(rdf(Class, rdf:type, rdfs:'Class'),(
        forall(rdfs_individual_of(Resource, Class),(
            forall(rdfs_class_property(Class, Property),(
                forall(rdf(Property, rdfs:domain, DomainClass),(
                    forall(rdf(Resource, Property, DomainResource),(
                        rdfs_individual_of(DomainResource, DomainClass2),
                        rdfs_subclass_of(DomainClass2, DomainClass)
                    ))
                ))
            ))
        ))
    )).