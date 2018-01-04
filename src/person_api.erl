%%%-------------------------------------------------------------------
%% @doc person_api public API
%% @end
%%%-------------------------------------------------------------------

-module(person_api).

-behaviour(application).


-export([start/0]).
-export([start/2]).
-export([stop/0]).
-export([stop/1]).
-export([start_phase/3]).

%% application
%% @doc Starts the application
start() ->
  application:ensure_all_started(person_api).

%% @doc Stops the application
stop() ->
  application:stop(person_api).

%% behaviour
%% @private
start(_StartType, _StartArgs) ->
  person_api_sup:start_link().

%% @private
stop(_State) ->
  ok = cowboy:stop_listener(person_api_http).

-spec start_phase(atom(), application:start_type(), []) -> ok | {error, term()}.
start_phase(start_trails_http, _StartType, []) ->
  Port = 
    case application:get_env(person_api, port) of
      {ok, Port1} -> list_to_integer(Port1);
      undefined   -> 8090
    end,
  {ok, ListenerCount} = application:get_env(person_api, http_listener_count),
  Trails = trails:trails([person_get_handler,
  						            person_post_handler,
                          person_put_handler,
                          cowboy_swagger_handler]),
  trails:store(Trails),
  Dispatch = trails:single_host_compile(Trails),
  RanchOptions = [{port, Port}],
  CowboyOptions =
    [
     {env,
      [
       {dispatch, Dispatch}
      ]},
     {compress, true},
     {timeout, 12000}
    ],
  {ok, _} =
    cowboy:start_http(person_api_http, ListenerCount, RanchOptions, CowboyOptions),
  ok.