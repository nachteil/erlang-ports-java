package com.student.erlang.senders;

/**
 * Created by yorg on 20.01.15.
 */
public interface ISender {

    public void sendAtom(String message);

    public void sendStructure(String structure);

    public void sendString(String string);

}
