-module(texas_example).

-behaviour(texas_handler).

-export([
    handle/2
]).

handle(Req, Opts) ->
    #{
        response_code => 200,
        response_body => io_lib:format("Hello World! ~p ~p", [Req, Opts]),
        response_headers => #{<<"content-type">> => <<"text/plain">>}
    }.
