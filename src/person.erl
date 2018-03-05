-module(person).
-export ([start/0, get_details/1, post_data/1]).

start() ->
 	ok.

get_details(_Req) ->
	{ok, jsx:encode([{<<"name">>, <<"raju">>}])}.

post_data(_Req) ->
	{ok, jsx:encode([{<<"ok">>, <<"postedd">>}])}.
