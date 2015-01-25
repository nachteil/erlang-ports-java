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

%% API
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3, await_reply_line/1, start_link/1, writeToEcho/1, line_loop/1, getPort/0, stopMe/0, changeCode/1]).

writeToEcho(Message) ->
  %%gen_server:cast(javaProxyServer, {sendToEcho, Message}),
  port_command(javka, Message),
  port_command(javka, "\n").

start_link(CommunicationType) ->
  gen_server:start_link({local, javaProxyServer}, javaProxyServer, CommunicationType, []).

init(CommunicationType) ->
  case os:find_executable("java") of
    false -> throw({error, java_not_in_path}) ;
    Java ->
      register(erlangPort, self()),
      PortName = {spawn_executable, Java},
      {Protocol, CommunicationTypeArgument} =
        case CommunicationType of
          line -> {{line,1024}, "line"} ;
          packet -> {{packet, 4}, "packet"} ;
          stream -> {stream, "stream"}
        end,
      PortSettings = [Protocol, stderr_to_stdout,
        {args, ["-jar", "priv/java-2-erl.jar", CommunicationTypeArgument]}],
      Port = erlang:open_port(PortName, PortSettings),
      register(javka, Port),
      case CommunicationType of
        line -> await_reply_line(Port) ;
        packet -> await_reply_packet(Port)
      end
  end.

getPort()->
  X = gen_server:call(var_server,{getPort}).

stopMe() ->
  gen_server:cast(var_server,stop).

changeCode(Name) ->
  ok = gen_server:call(var_server,{change,Name}).

handle_call({getPort}, _From, Value) ->
  {noreply, Value, Value};

handle_call({change,Name},_From,Value) ->
  io:format("sending msg to port ~p~n",[Value]),
  Value  ! {self(), {command, "{msg,{change}}."}},
  {reply, ok,Value}.

handle_cast(ready, Value) ->
  io:format("Java is ready for work!"),
  {noreply,Value};

handle_cast({wrong, What}, Value) ->
  io:format("Java recevied wrong data ~p~n",[What]),{noreply,Value};

handle_cast(notready, Value) ->
  {stop, "Java is not responding properly", []};

handle_cast(stop,Value)->
  Value ! {command,"stop."},
  {stop, normal, shutdown_ok, Value}.

handle_info(Info, Port) ->
  case Info of
    {Port, {data, {eol, IncomingMessage}}}->
      {ok, Tokens, _} = erl_scan:string(IncomingMessage),   %%Parsing msg to tuple {msg,MSG}
      {ok, Expr} = erl_parse:parse_term(Tokens),
      case Expr of {msg,Msg} ->   %io:format("javaProxyServer: got Message from java: ~p~n", [Msg]),
        case Msg of
          {ok,ready}    -> gen_server:cast(var_server, ready);
          {ok,Z}        -> gen_server:cast(var_server, Z);
          {wrong,What}  -> gen_server:cast(var_server, {wrong, What});
          _             -> gen_server:cast(var_server, notready)
        end;
        U ->
          io:format("javaProxyServer: got uknown format message from java: ~p~n", [U]),
          gen_server:cast(var_server,notready)
      end;
    _->true end,
  {noreply, Port}.

terminate(_, Value) ->
  io:format("Stoping server."),
  port_close(Value),
  ok.

code_change(_, _, _) ->
  erlang:error(not_implemented).

line_loop(Port) ->
  receive
    {Port, {data, {eol, Message}}} ->
      io:format("Line mesg: ~p~n", [Message]),
      line_loop(Port),
      {ok, Port} ;

    Info ->
      case handle_info(Info, Port) of
        {noreply, NewState} ->
          line_loop(NewState);
        {stop, Reason, _NewState} ->
          {stop, Reason}
      end
  end.

await_reply_line(Port) ->
  receive
    {Port, {data, {eol, "No elo"}}} ->
      io:format("javaProxyServer: Java node confirmed ready~n"),
      {ok, Port} ;
    Info ->
      case handle_info(Info, Port) of
        {noreply, NewState} ->
          {ok, NewState} ;
        {stop, Reason, _NewState} ->
          {stop, Reason}
      end
  end.

await_reply_packet(Port) ->
  receive
    {Port, {data, {eol, "No elo"}}} ->
      io:format("javaProxyServer: Java node confirmed ready~n"),
      {ok, Port} ;

    Info ->
      case handle_info(Info, Port) of
        {noreply, NewState} ->
          await_reply_packet(NewState);
        {stop, Reason, _NewState} ->
          {stop, Reason}
      end
  end.