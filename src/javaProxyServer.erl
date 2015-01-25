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

%% API
-export([init/1, handle_info/2, terminate/2, code_change/3, start_link/1, writeToEcho/1, getPort/0, stopMe/0, loop/2, stop_java/1]).

writeToEcho(Message) ->
  %%gen_server:cast(javaProxyServer, {sendToEcho, Message}),
  erlangPort ! {echo, Message},
  message_sent.

start_link(CommunicationType) ->
  spawn(javaProxyServer, init, [CommunicationType]).

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
      loop(CommunicationType, Port)
  end.

getPort()->
  erlangPort ! {get_port, self()}.

stopMe() ->
  gen_server:cast(javaProxyServer,stop).

stop_java(Port) ->
  Port ! {command,"stop."},
  {stop, "user requested java termination~n"}.

handle_info(Info, Port) ->
  case Info of

%%  Communication from erlang

    {get_port, Sender} ->
      Sender ! self(),
      {continue, Port} ;

    {echo, Message} ->
      port_command(javka, string:concat(Message, "\n")),
      {continue, Port} ;

%%  Communication from Java

    {Port, {data, {eol, IncomingMessage}}}->
      {ok, Tokens, _} = erl_scan:string(IncomingMessage),   %%Parsing msg to tuple {msg,MSG}
      {ok, Expr} = erl_parse:parse_term(Tokens),
      case Expr of
        {msg,Msg} ->   %io:format("javaProxyServer: got Message from java: ~p~n", [Msg]),
          case Msg of
            {ok,ready}    -> io:format("Java is ready for work!~n") ;
            {ok,Z}        -> io:format("javaProxyServer: received message:~n~p~n", [Z]);
            {wrong,What}  -> io:format("Java recevied wrong data ~p~n",[What])
          end,
          {continue, Port};
        U ->
          io:format("javaProxyServer: got uknown format message from java: ~p~n", [U]),
          {continue, Port}
      end;
    Anything ->
      io:format("Unrecognized incoming message:~p~n", [Anything]),
      {continue, Port}
  end.

terminate(_, Value) ->
  io:format("Stoping server.~n"),
  port_close(Value),
  ok.

code_change(_, _, _) ->
  erlang:error(not_implemented).

loop(line, Port) ->
  receive
    Info ->
      case handle_info(Info, Port) of
        {stop, Reason}  -> {stop, Reason} ;
        {continue, Port} -> loop(line, Port)
      end
  end ;

loop(packet, _) ->
  erlang:error(not_implemented).
