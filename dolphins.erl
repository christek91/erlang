-module(dolphins).
-compile(export_all).

dolphin1() ->
	receive
		do_a_flip ->
			io:format("How about no?~n");
		fish ->
			io:format("Nom~n");
		_ ->
			io:format("Heh~n")
	end.

dolphin2() ->
	receive
		{From, do_a_flip} ->
			From ! "How about no?";
		{From, fish} ->
			From ! "Nom.";
		_ ->
			io:format("Heh~n")
	end.

dolphin3() ->
	receive
		{From, do_a_flip} ->
			From ! "How about no?",
			dolphin3();
		{From, fish} ->
			From ! "Nom. Bye!";
		_ ->
			io:format("Heh~n"),
			dolphin3()
	end.
