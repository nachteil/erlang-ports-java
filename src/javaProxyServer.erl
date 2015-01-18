%%%-------------------------------------------------------------------
%%% @author yorg
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 17. sty 2015 14:19
%%%-------------------------------------------------------------------
-module(javaProxyServer).
-author("yorg").

-behaviour(gen_server).

-record(state, {java_port, java_node}).

%% API
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

init(_) ->
  case os:find_executable("java") of
    false -> throw({error, java_not_in_path}) ;
    Java ->
      ThisNode = atom_to_list(node()),
      JavaNodeName =
        case string:tokens(ThisNode, "@") of
          [Name, Server] -> list_to_atom(Name ++ "_java@" ++ Server) ;
          _Node -> throw({bad_node_name, node()})
        end,
      PortName = {spawn_executable, Java},
      PortSettings = [{line, 1024}, stderr_to_stdout, {args, ["-jar", "priv/java-2-erl.jar",  ThisNode, JavaNodeName, erlang:get_cookie()]} ],
      Port = erlang:open_port(PortName, PortSettings),
      await_reply(#state{java_port = Port, java_node = JavaNodeName})
  end.

handle_call(_, _, _) ->
  erlang:error(not_implemented).

handle_cast(_, _) ->
  erlang:error(not_implemented).

handle_info(Info, _) ->
  io:format("Got info to handle: ~p~n", [Info]).

terminate(_, _) ->
  ok.

code_change(_, _, _) ->
  erlang:error(not_implemented).

await_reply(State = #state{java_port = Port}) ->
  receive
    Info ->
      case handle_info(Info, State) of
        {noreply, NewState} ->
          await_reply(NewState);
        {stop, Reason, _NewState} ->
          {stop, Reason}
      end;
    {Port, {data, {eol, "READY"}}} ->
      true = erlang:monitor_node(State#state.java_node, true),
      {ok, State}
  end.