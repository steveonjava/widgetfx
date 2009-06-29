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
import java.io.StringReader;
import java.net.URLDecoder;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.Properties;

/**
 * @author Stephen Chin
 * @author Keith Combs
 */
public class CommunicationProtocol {
    public static final String PORT = "port";
    public static final String CONNECTED = "connected";

    private CommandProcessor processor;

    public CommunicationProtocol(CommandProcessor commandProcessor) {
        processor = commandProcessor;
    }

    String processInput(String inputLine) {
        String[] args = inputLine.split("\\|");
        String command = args[0];
        if (command.equals(PORT)) {
            CommunicationManager.INSTANCE.connectTo(Integer.parseInt(args[1]));
            return CONNECTED;
        } else if (command.equals("hover")) {
            return String.valueOf(processor.hover(Float.parseFloat(args[1]), Float.parseFloat(args[2]), Float.parseFloat(args[3])));
        } else if (command.equals("finishHover")) {
            try {
                Properties properties = new Properties();
                properties.load(new StringReader(URLDecoder.decode(args[4], "UTF-8")));
                return String.valueOf(processor.finishHover(args[1], Float.parseFloat(args[2]), Float.parseFloat(args[3]), properties));
            } catch (IOException ex) {
                Logger.getLogger(CommunicationProtocol.class.getName()).log(Level.SEVERE, "Unable to load properties: " + args[4], ex);
            }
        } else {
            Logger.getLogger(CommunicationReceiver.class.getName()).log(Level.WARNING, "Unknown Command: " + inputLine);
        }
        return null;
    }

}
