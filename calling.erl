-module(calling).
-export([listener/0]).

listener() ->
  receive
  	{intro, Master, {sender, From, receiver, To}} ->
  		{_, _, Ms} = erlang:now(),
  		timer:sleep(rand:uniform(100)),
        Master ! {intro, From, To, Ms},
        whereis(From) ! {reply, Master, {sender, To, receiver, From}, Ms},
        listener();
    {reply, Master, {sender, From, receiver, To}, Ms} ->
  		timer:sleep(rand:uniform(100)),
        Master ! {reply, From, To, Ms},
        listener();
    {Master, From, {receivers, Data}} ->
      	[self() ! {intro, Master, {sender, From, receiver, To}} || To <- Data],
      	listener()
    after 5000 ->
      	io:fwrite("~nProcess ~w has received no calls for 5 seconds, ending...~n", [element(2, erlang:process_info(self(), registered_name))])
  end.
