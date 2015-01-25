package com.student.erlang.senders;

import java.io.IOException;
import java.io.OutputStream;

/**
 * Created by yorg on 20.01.15.
 */
public class PacketSender implements ISender {

    OutputStream writer = System.out;

    @Override
    public void sendString(String string) {

    }

    @Override
    public void sendStructure(String structure) {

    }

    @Override
    public void sendAtom(String message) {
        byte [] messageBytes = message.getBytes();
        int msgLen = messageBytes.length;
        try {
            writer.write(new byte[] {((byte) (msgLen & 0xff))});
            writer.write(messageBytes);
            writer.flush();
        } catch (IOException e) {
            System.err.println();
        }
    }
}
