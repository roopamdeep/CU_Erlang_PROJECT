-module(exchange).
-export([start/0]).

parse() ->
	{ok, Calls} = file:consult("calls.txt"),
	Calls.

start() ->
	Calls = parse(),
	io:fwrite("~n* * Calls to be made * * ~n", []),
	[io:fwrite("~w: ~w ~n", [element(1, Contact), element(2, Contact)]) || Contact <- Calls],
	io:fwrite("~n", []),
	[register(element(1, Contact), spawn(calling, listener, [])) || Contact <- Calls],
	call(Calls),
	receipts().

call(Calls) ->
	[ whereis(element(1, Contact)) ! {self(), element(1, Contact), {receivers, element(2, Contact)}} || Contact <- Calls].

receipts() ->
	receive
		{intro, From, To, Ms} ->
			io:fwrite("~w received intro message from ~w [~w]\n", [To, From, Ms]),
			receipts();
		{reply, From, To, Ms} ->
			io:fwrite("~w received reply message from ~w [~w]\n", [To, From, Ms]),
			receipts()
		after 10000 ->
        	io:fwrite("~nMaster has received no replies for 10 seconds, ending...~n", [])
	end.
