-module(person_post_handler).


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
          handle_post/2
        ]).

%trails
-behaviour(trails_handler).
-export([trails/0]).

trails() ->
    DataDefinition     = <<"DataPersonInfo">>,
    DataDefProperties  = person_swagger:get_definition(data_person_info),
    DataReqFieldsList  = person_swagger:get_req_fields(DataDefProperties, []),
    ok = person_swagger:add_definition(DataDefinition, DataDefProperties, DataReqFieldsList),

    DefinitionName = <<"PersonInfo">>,
    DefinitionProperties = person_swagger:get_definition(person_info),
    ReqFieldsList        = person_swagger:get_req_fields(DefinitionProperties, []),
    ok = person_swagger:add_definition(DefinitionName, DefinitionProperties, ReqFieldsList),

    Metadata =
        #{post =>
            #{tags              => ["person_post_handler"],
              description       => "person_post_handler",
              produces          => ["application/json"],
              consumes          => ["application/json"],
              parameters        => person_swagger:get_params(<<"PersonInfo">>),
              responses         => person_swagger:invalid_headers_resp()
            }  
        },
    [trails:trail("/person/post_data", person_post_handler, [], Metadata)].

%% cowboy
allowed_methods(Req, State) ->
    {[<<"POST">>], Req, State}.

handle_post(Req, State) ->
    {ok, ReqBody, Req2} = cowboy_req:body(Req),
    Reply = person:post_data(ReqBody),
    Req1  =  cowboy_req:set_resp_body(Reply, Req2),
    {true, Req1, State}.