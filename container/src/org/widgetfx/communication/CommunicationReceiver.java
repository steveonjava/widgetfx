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
public class CommunicationReceiver implements Runnable {
    private Socket sender;
    private CommandProcessor processor;

    CommunicationReceiver(Socket sender, CommandProcessor processor) {
        Logger.getLogger(CommunicationSender.class.getName()).log(Level.INFO, "CommunicationReceiver connect to sender = " + sender);
        this.sender = sender;
        this.processor = processor;
    }

    public void run() {
        try {
            PrintWriter out = new PrintWriter(sender.getOutputStream(), true);
            BufferedReader in = new BufferedReader(new InputStreamReader(sender.getInputStream()));
            String inputLine;
            String outputLine;
            // initiate conversation with client
            CommunicationProtocol cp = new CommunicationProtocol(processor);
            while ((inputLine = in.readLine()) != null) {
                outputLine = cp.processInput(inputLine);
                out.println(outputLine);
            }
        } catch (SocketException ex) {
            Logger.getLogger(CommunicationReceiver.class.getName()).log(Level.INFO, "Socket closed, disconnecting from: " + sender);
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
