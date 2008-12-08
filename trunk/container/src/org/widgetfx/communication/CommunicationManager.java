/*
 * WidgetFX - JavaFX Desktop Widget Platform
 * Copyright (C) 2008  Stephen Chin
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.

 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.

 * This particular file is subject to the "Classpath" exception as provided
 * in the LICENSE file that accompanied this code.

 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
package org.widgetfx.communication;

import java.io.IOException;
import java.net.ConnectException;
import java.net.ServerSocket;
import java.net.Socket;
import java.net.UnknownHostException;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * @author Stephen Chin
 * @author Keith Combs
 */
public enum CommunicationManager implements Runnable {
    INSTANCE;

    public static final int STARTING_PORT = 34900;

    public static final int SEARCH_DEPTH = 20;

    private int serverPort;

    private ServerSocket serverSocket;

    private List<CommunicationSender> senders = new ArrayList<CommunicationSender>();

    private CommandProcessor processor;

    public void startServer() {
        new Thread(new ServerStartThread(), "Communication Server Search Thread").start();
    }

    public void setCommandProcessor(CommandProcessor processor) {
        this.processor = processor;
    }

    public String[] broadcast(String command, String[] args) {
        List<String> result = new ArrayList<String>();
        for (CommunicationSender sender : senders) {
            result.add(sender.send(command, args));
        }
        return result.toArray(new String[result.size()]);
    }

    @Override
    public void run() {
        while (true) {
            try {
                Socket client = serverSocket.accept();
                Thread serverThread = new Thread(new CommunicationReceiver(client, processor), "Communication Receiver");
                serverThread.setDaemon(true);
                serverThread.start();
            } catch (IOException ex) {
                Logger.getLogger(CommunicationManager.class.getName()).log(Level.SEVERE, null, ex);
            }
        }
    }

    public void connectTo(int port) {
        try {
            Socket socket = new Socket((String) null, port);
            senders.add(new CommunicationSender(socket));
        } catch (IOException ex) {
            Logger.getLogger(CommunicationManager.class.getName()).log(Level.SEVERE, null, ex);
        }
    }

    public void removeSender(CommunicationSender sender) {
        senders.remove(sender);
    }

    class ServerStartThread implements Runnable {

        public ServerStartThread() {
        }

        @Override
        public void run() {
            try {
                int port = STARTING_PORT;
                int misses = 0;
                List<CommunicationSender> newSenders = new ArrayList<CommunicationSender>();
                while (misses < SEARCH_DEPTH) {
                    try {
                        Socket socket = new Socket((String) null, port);
                        newSenders.add(new CommunicationSender(socket));
                    } catch (UnknownHostException ex) {
                        Logger.getLogger(CommunicationManager.class.getName()).log(Level.SEVERE, "Communication Server can't start up due to UnknownHostException", ex);
                    } catch (ConnectException ex) {
                        misses++;
                        if (serverSocket == null) {
                            startCommunicationServer(port);
                            senders.addAll(newSenders);
                            for (CommunicationSender sender : newSenders) {
                                sender.sendPort(serverPort);
                            }
                            newSenders = senders;
                        }
                    }
                    port++;
                }
            } catch (IOException ex) {
                Logger.getLogger(CommunicationManager.class.getName()).log(Level.SEVERE, "Communication Server can't start up due to IOException", ex);
            }
        }

        private void startCommunicationServer(int port) throws IOException {
            serverPort = port;
            serverSocket = new ServerSocket(port);
            Thread connectionListener = new Thread(CommunicationManager.this, "Communication Server");
            connectionListener.setDaemon(true);
            connectionListener.start();
        }
    }
}
