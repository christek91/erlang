-module(linkmon).
-compile(export_all).


myproc() ->
	timer:sleep(5000),
	exit(reason).

chain(0) ->
	receive
		_ -> ok
	after 2000 ->
		exit("chain dies here")
	end;
chain(N) ->
	% Pid = spawn(fun() -> chain(N-1) end),
	% link(Pid),
	spawn_link(fun() -> chain(N-1) end),
	receive
		_ -> ok
	end.

start_critic() ->
	spawn(?MODULE, critic, []).

judge(Pid, Band, Album) ->
	Pid ! {self(), {Band, Album}},
	receive
		{Pid, Criticisim} -> Criticisim
	after 2000 ->
		timeout
	end.

critic() ->
	receive
		{From, {"RATM", "Unit Testify"}} ->
			From ! {self(), "10/10"};
		{From, {"System of a Down", "Memoize"}} ->
			From ! {self(), "Not johnny cash, but good."};
		{From, {"Johnny Cash", "Token ring of fire"}} ->
			From ! {self(), "Incredible"};
		{From, {_Band, _Album}} ->
			From ! {self(), "Terrible"}
	end,
	critic().

start_critic2() ->
	spawn(?MODULE, restarter, []).

restarter() ->
	process_flag(trap_exit, true),
	Pid = spawn_link(?MODULE, critic2, []),
	% Pid = spawn(?MODULE, critic2, []),
	register(critic, Pid),
	receive
		{'EXIT', Pid, normal} -> % not a crash
			ok;
		{'EXIT', Pid, shutdown} -> % manual termination
			ok;
		{'EXIT', Pid, _} ->
			restarter()
	end.

judge2(Band, Album) ->
	Ref = make_ref(),
	critic ! {self(), Ref, {Band, Album}},
	receive
		{Ref, Criticisim} -> Criticisim
	after 2000 ->
		timeout
	end.

critic2() ->
	receive
		{From, Ref, {"RATM", "Unit Testify"}} ->
			From ! {Ref, "10/10"};
		{From, Ref, {"System of a Down", "Memoize"}} ->
			From ! {Ref, "Not johnny cash, but good."};
		{From, Ref, {"Johnny Cash", "Token ring of fire"}} ->
			From ! {Ref, "Incredible"};
		{From, Ref, {_Band, _Album}} ->
			From ! {Ref, "Terrible"}
	end,
	critic2().

