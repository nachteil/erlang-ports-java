package com.student.erlang.senders;

import com.student.erlang.senders.ISender;

/**
 * Created by yorg on 20.01.15.
 */
public class LineSender implements ISender {

    @Override
    public void sendMessage(String message) {
        System.out.println(message);
    }
}
