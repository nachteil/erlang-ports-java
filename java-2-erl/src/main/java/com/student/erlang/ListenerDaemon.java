package com.student.erlang;

import com.student.erlang.listeners.IListener;
import com.student.erlang.senders.ISender;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;

/**
 * Created by yorg on 20.01.15.
 */
public class ListenerDaemon implements Runnable {

    private final IListener listener;
    private final ISender sender;

    BufferedReader reader = new BufferedReader(new InputStreamReader(System.in));

    public ListenerDaemon(IListener listener, ISender sender) {
        this.listener = listener;
        this.sender = sender;
    }

    String shaRegex = "{hash,.+?}";

    @Override
    public void run() {
        while (true) {
            int prev = 0;
            try {
                if (System.in.available() != prev) {
                    prev = System.in.available();
                    System.out.println("rw");
                }

            } catch (IOException e) {
                e.printStackTrace();
            }
        }

    }
}