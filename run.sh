#!/bin/sh

cd application
erl -eval "code:load_abs(\"ebin/javaProxyServer\"), javaProxyServer:start_link($1)."