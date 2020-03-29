:- module(errorpage, []).

:- multifile http:status_page/3.

http:status_page(not_found(URL), _Context, HTML) :-
    phrase(page([ title('Page not found')],
        {|html(URL)||
        <h1>Page not found</h1>
        <p>The requested page was not found in the server</p>
        <hr>
        <p><b>Lyncex</b></p>
        |}),HTML).