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

    public void sendPort(int port) {
        send("port", new String[] {String.valueOf(port)});
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
