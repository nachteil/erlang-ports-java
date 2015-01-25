package com.student.erlang.listeners;

import java.io.BufferedReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStreamReader;

/**
 * Created by yorg on 20.01.15.
 */
public class LineListener implements IListener{

    BufferedReader reader = new BufferedReader(new InputStreamReader(System.in));

    @Override
    public String listen() {
        try {
            return reader.readLine();
        } catch (IOException e) {
            try {
                new FileWriter("raport.ter").write("error: " + e);
            } catch (IOException e1) {

            }
        }
        return "";
    }
}
