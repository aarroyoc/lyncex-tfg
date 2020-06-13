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

:- begin_tests(setup).

test(get_dict_function) :-
    once(get_dict_function(id, _{id:42}, 42)).

test(get_dict_function_false) :-
    get_dict_function(id, _{x:32}, false).

:- end_tests(setup).