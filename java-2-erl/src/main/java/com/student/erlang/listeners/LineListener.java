package com.student.erlang.listeners;

import java.util.Scanner;

/**
 * Created by yorg on 20.01.15.
 */
public class LineListener implements IListener{

    Scanner scanner = new Scanner(System.in);

    @Override
    public String listen() {
        return scanner.nextLine();
    }
}
