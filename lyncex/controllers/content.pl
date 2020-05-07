:- module(content, [content_controller/3]).

:- use_module(library(semweb/rdfs)).
:- use_module(library(semweb/rdf11)).

% ContentController / Base64
content_controller(Path, _Method, _Request) :-
    rdfs_individual_of(Controller, lyncex:'ContentController'),
    rdf(Controller, lyncex:url, Path^^xsd:string),
    rdf(Controller, lyncex:content, Content),
    rdf(Controller, lyncex:mime, ContentMIME^^xsd:string),
    rdfs_individual_of(Content, cnt:'ContentAsBase64'),
    rdf(Content, cnt:bytes, BytesBase64^^xsd:string),
    base64(Bytes, BytesBase64),
    string_codes(Bytes, OutBytes),
    throw(http_reply(bytes(ContentMIME, OutBytes))).


% ContentController / Text
content_controller(Path, _Method, _Request) :-
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