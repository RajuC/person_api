-module(person_get_handler).

-include_lib("mixer/include/mixer.hrl").
-mixin([
        {person_api_default,
         [
          init/3,
          rest_init/2,
          content_types_provided/2,
          content_types_accepted/2,
          resource_exists/2,
          options/2
         ]}
       ]).

-export([ allowed_methods/2,
          handle_get/2
        ]).


%trails
-behaviour(trails_handler).
-export([trails/0]).

trails() ->
  Metadata =
    #{get =>
	      #{tags           => ["Person Details"],
	        description    => "Person Details.",
	        produces       => [<<"text/plain">>],
          responses      => #{<<"502">> =>
                               #{<<"description">> => "{Person Details Error}"}}
            }
    },
   [trails:trail("/person/get_data", person_get_handler, [], Metadata)].

%% cowboy
allowed_methods(Req, State) ->
    {[<<"GET">>], Req, State}.


handle_get(Req, State) ->
        case person:details(Req) of
            {ok, Data}         ->
                {Data, Req, State};
            {error, ReasonBin}    ->
                Reply = <<"{Unable to Read Person Details. Reason is", ReasonBin/binary, "}">>,
                {ok, Req2}  = cowboy_req:reply(502, [], Reply, Req),
                {halt, Req2, State}
        end.

