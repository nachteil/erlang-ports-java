package com.student.erlang.senders;

/**
 * Created by yorg on 20.01.15.
 */
public class LineSender implements ISender {

    @Override
    public void sendAtom(String message) {
        System.out.println("{msg,{ok," + message + "}}.");
    }

    @Override
    public void sendStructure(String structure) {
        System.out.println("{msg,{ok," + structure + "}}.");
    }

    @Override
    public void sendString(String s) {
        System.out.println("{msg,{ok,\"" + s + "\"}}.");
    }
}
