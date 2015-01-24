package com.student.erlang.listeners;

import java.util.Scanner;

/**
 * Created by yorg on 20.01.15.
 */
public class PacketListener implements IListener {

    Scanner scanner = new Scanner(System.in);

    @Override
    public String listen() {
        int msgLen = scanner.nextByte() & 0xff;
        byte [] msgBytes = new byte[msgLen];
        for(int i = 0; i < msgLen; ++i) {
            msgBytes[i] = scanner.nextByte();
        }
        return new String(msgBytes);
    }
}
