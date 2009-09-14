/*
 * WidgetFX - JavaFX Desktop Widget Platform
 * Copyright (c) 2008-2009, WidgetFX Group
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 1. Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 * 3. Neither the name of WidgetFX nor the names of its contributors may be used
 *    to endorse or promote products derived from this software without
 *    specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
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

        public void run() {
            try {
                int port = STARTING_PORT;
                int misses = 0;
                List<CommunicationSender> newSenders = new ArrayList<CommunicationSender>();
                while (misses < SEARCH_DEPTH) {
                    try {
                        Socket socket = new Socket((String) null, port);
                        if (serverSocket != null) {
                            CommunicationSender sender = new CommunicationSender(socket);
                            newSenders.add(sender);
                            if (!sender.sendPort(serverPort)) {
                                misses++;
                            }
                        } else {
                            Logger.getLogger(CommunicationManager.class.getName()).log(Level.WARNING, "ServerSocket is null.  Trying to start one on port: "+port);
                            socket.close();
                            startCommunicationServer(port);
                            misses++;
                        }
                    } catch (UnknownHostException ex) {
                        Logger.getLogger(CommunicationManager.class.getName()).log(Level.SEVERE, "Communication Server can't start up due to UnknownHostException", ex);
                    } catch (ConnectException ex) {
                        Logger.getLogger(CommunicationManager.class.getName()).log(Level.INFO, "Unable to connect to port: "+port);
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
            System.out.println("Started WidgetFX server on port " + port);
            Thread connectionListener = new Thread(CommunicationManager.this, "Communication Server");
            connectionListener.setDaemon(true);
            connectionListener.start();
        }
    }
}
