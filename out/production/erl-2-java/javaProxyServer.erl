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
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3, await_reply_line/1, start_link/1]).

start_link(CommunicationType) ->
  gen_server:start_link({local, javaProxyServer}, javaProxyServer, CommunicationType, []).

init(CommunicationType) ->
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
      {Protocol, Arg} =
        case CommunicationType of
          line -> {{line,1024}, "line"} ;
          packet -> {{packet, 1}, "packet"} ;
          stream -> {stream, "stream"}
        end,
      PortSettings = [Protocol, stderr_to_stdout,
        {args, ["-jar", "priv/java-2-erl.jar", Arg,  ThisNode, JavaNodeName, erlang:get_cookie()]} ],
      Port = erlang:open_port(PortName, PortSettings),
      case CommunicationType of
        line -> await_reply_line(#state{java_port = Port, java_node = JavaNodeName}) ;
        packet -> await_reply_packet(#state{java_port = Port, java_node = JavaNodeName})
      end
  end.

handle_call(_, _, _) ->
  erlang:error(not_implemented).

handle_cast(_, _) ->
  erlang:error(not_implemented).

handle_info(Info, State) ->
  io:format("javaProxyServer: Got info to handle: ~p~n", [Info]),
  {noreply, State}.

terminate(_, _) ->
  ok.

code_change(_, _, _) ->
  erlang:error(not_implemented).

await_reply_line(State = #state{java_port = Port}) ->
  receive
    {Port, {data, {eol, "No elo"}}} ->
      io:format("javaProxyServer: Java node confirmed ready~n"),
      {ok, State} ;

    Info ->
      case handle_info(Info, State) of
        {noreply, NewState} ->
          await_reply_line(NewState);
        {stop, Reason, _NewState} ->
          {stop, Reason}
      end
  end.

await_reply_packet(State = #state{java_port = Port}) ->
  receive
    {Port, {data, {eol, "No elo"}}} ->
      io:format("javaProxyServer: Java node confirmed ready~n"),
      {ok, State} ;

    Info ->
      case handle_info(Info, State) of
        {noreply, NewState} ->
          await_reply_packet(NewState);
        {stop, Reason, _NewState} ->
          {stop, Reason}
      end
  end.