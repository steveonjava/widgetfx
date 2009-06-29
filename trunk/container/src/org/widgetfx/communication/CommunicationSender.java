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

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.Socket;
import java.net.SocketException;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * @author Stephen Chin
 * @author Keith Combs
 */
public class CommunicationSender {
    private Socket socket;
    private PrintWriter out;
    private BufferedReader in;

    public CommunicationSender(Socket socket) throws IOException {
        Logger.getLogger(CommunicationSender.class.getName()).log(Level.INFO, "CommunicationSender hooked up to socket = " + socket);
        this.socket = socket;
        out = new PrintWriter(socket.getOutputStream(), true);
        in = new BufferedReader(new InputStreamReader(socket.getInputStream()));
    }

    public boolean sendPort(int port) {
        return CommunicationProtocol.CONNECTED.equals(send(CommunicationProtocol.PORT, new String[] {String.valueOf(port)}));
    }

    public String send(String command, String args[]) {
        try {
            StringBuffer commandString = new StringBuffer();
            commandString.append(command);
            if (args != null) {
                for (String arg : args) {
                    commandString.append('|');
                    commandString.append(arg);
                }
            }
            out.println(commandString.toString());
            if (out.checkError()) {
                Logger.getLogger(CommunicationSender.class.getName()).log(Level.INFO, "Got an error, disconnecting from: " + socket);
                close();
                return null;
            }
            return in.readLine();
        } catch (SocketException ex) {
            Logger.getLogger(CommunicationSender.class.getName()).log(Level.INFO, "Got an exception, disconnecting from: " + socket);
            close();
        } catch (IOException ex) {
            Logger.getLogger(CommunicationSender.class.getName()).log(Level.SEVERE, null, ex);
        }
        return null;
    }

    private void close() {
        try {
            socket.close();
        } catch (IOException ex) {
            Logger.getLogger(CommunicationSender.class.getName()).log(Level.SEVERE, null, ex);
        }
        CommunicationManager.INSTANCE.removeSender(this);
    }

}
