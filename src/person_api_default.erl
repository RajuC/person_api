-module(person_api_default).

-export([init/3,
         rest_init/2,
         content_types_accepted/2,
         content_types_provided/2,
         forbidden/2,
         resource_exists/2,
         options/2
        ]).

%% cowboy
init(_Transport, _Req, _Opts) ->
  {upgrade, protocol, cowboy_rest}.

rest_init(Req, _Opts) ->
  {Path, Req1} = cowboy_req:path(Req),
  lager:info("||Input Req Endpoint: ~p", [Path]),
  {ok, Req1, #{}}.

content_types_accepted(Req, State) ->
       case cowboy_req:method(Req) of
         {<<"POST">>, _ } ->
           {[{'*', handle_post}], Req, State};
         {<<"PUT">>, _ } ->
           {[{'*', handle_put}], Req, State}
       end.

content_types_provided(Req, State) ->
  {[{<<"text/plain">>,        handle_get},
    {<<"application/json">>,  handle_get},
    {<<"text/html">>,         handle_get}
  ], Req, State}.

forbidden(Req, State) ->
  {false, Req, State}.

resource_exists(Req, State) ->
  {true, Req, State}.

options(Req, State) ->
    % Req1 = cowboy_req:set_resp_header(<<"access-control-allow-methods">>, <<"GET, OPTIONS, PUT, PATCH, DELETE, POST">>, Req),
    Req1 = cowboy_req:set_resp_header(<<"access-control-allow-origin">>, <<"*">>, Req),
    {ok, Req1, State}.
