package com.student.erlang;

import com.student.erlang.listeners.IListener;
import com.student.erlang.listeners.LineListener;
import com.student.erlang.listeners.PacketListener;
import com.student.erlang.senders.ISender;
import com.student.erlang.senders.LineSender;
import com.student.erlang.senders.PacketSender;

import java.io.FileWriter;
import java.io.IOException;

/**
 * Created by yorg on 18.01.15.
 */
public class App {

    public static void main( String ... args ) throws IOException, InterruptedException {

        IListener listener = null;
        ISender sender = null;

        FileWriter writer = new FileWriter("msg.log");

        switch (args[0]) {
            case "line":
                listener = new LineListener();
                sender = new LineSender();
                break;
            case "packet":
                listener = new PacketListener();
                sender = new PacketSender();
                break;
            default:
                System.exit(-1);
        }

        sender.sendAtom("ready");

        while(true) {
            String msg = listener.listen();
            sender.sendString(msg);

            writer.write(msg);
            writer.write("\n");
            writer.flush();
        }
    }

}
