:- module(setup, [setup/0]).

:- use_module(library(semweb/rdf11)).
:- use_module(library(semweb/rdfs)).

:- use_module(library(st/st_expr)).

setup :-
    forall(rdfs_individual_of(Prefix, lyncex:'Prefix'),(
        rdf(Prefix, lyncex:namespace, Namespace^^xsd:string),
        rdf(Prefix, lyncex:prefix_name, Name^^xsd:string),
        atom_string(NamespaceAtom, Namespace),
        atom_string(NameAtom, Name),
        rdf_register_prefix(NameAtom, NamespaceAtom)
    )),
    st_set_function(exists, 2, get_dict_function).

get_dict_function(Key, Dict, Value) :-
    get_dict(Key, Dict, Value);Value = false.