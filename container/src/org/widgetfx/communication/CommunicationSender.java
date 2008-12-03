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
        System.out.println("CommunicationSender hooked up to socket = " + socket);
        this.socket = socket;
        out = new PrintWriter(socket.getOutputStream(), true);
        in = new BufferedReader(new InputStreamReader(socket.getInputStream()));
    }

    public void sendPort(int port) {
        out.println(String.valueOf(port));
        if (out.checkError()) {
            close();
        }
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
