%%%-------------------------------------------------------------------
%%% @author yorg
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 18. sty 2015 22:03
%%%-------------------------------------------------------------------
-module(javaProxySup).
-author("yorg").

-behaviour(supervisor).

%% API
-export([init/1, startJavaProxyServer/1]).

startJavaProxyServer(CommunicationType) ->
  SupervisorNameTuple = {local, javaProxySup},
  supervisor:start_link(SupervisorNameTuple, ?MODULE, [CommunicationType]).

init(CommunicationType) ->
  io:format("javaProxySup: Initializing new process~n"),
  ChildId = javaProxyServer,
  ChildStartFunc = {javaProxyServer, start_link, CommunicationType},
  Restart = permanent,
  Shutdown = brutal_kill,
  Type = worker,
  Modules = [javaProxyServer],
  RestartStrategy = one_for_one,
  MaxR = 5,
  MaxT = 1,
  ChildSpec = {ChildId, ChildStartFunc, Restart, Shutdown, Type, Modules},
  {ok, {{RestartStrategy, MaxR, MaxT}, [ChildSpec]}}.
