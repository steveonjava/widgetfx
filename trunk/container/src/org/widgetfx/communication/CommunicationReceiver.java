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
public class CommunicationReceiver implements Runnable {
    private Socket sender;

    CommunicationReceiver(Socket sender) {
        System.out.println("CommunicationReceiver connect to sender = " + sender);
        this.sender = sender;
    }

    @Override
    public void run() {
        try {
            PrintWriter out = new PrintWriter(sender.getOutputStream(), true);
            BufferedReader in = new BufferedReader(new InputStreamReader(sender.getInputStream()));
            String inputLine;
            String outputLine;
            // initiate conversation with client
            CommunicationProtocol cp = new CommunicationProtocol();
            String port = in.readLine();
            CommunicationManager.INSTANCE.connectTo(Integer.parseInt(port));
            while ((inputLine = in.readLine()) != null) {
                outputLine = cp.processInput(inputLine);
                out.println(outputLine);
            }
        } catch (SocketException ex) {
            // socket closed, shutting down thread gracefully
        } catch (IOException ex) {
            Logger.getLogger(CommunicationReceiver.class.getName()).log(Level.SEVERE, null, ex);
        } finally {
            try {
                sender.close();
            } catch (IOException ex) {
                Logger.getLogger(CommunicationReceiver.class.getName()).log(Level.SEVERE, null, ex);
            }
        }
    }
}
