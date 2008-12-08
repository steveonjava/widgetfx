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

import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * @author Stephen Chin
 * @author Keith Combs
 */
public class CommunicationProtocol {
    private CommandProcessor processor;

    public CommunicationProtocol(CommandProcessor commandProcessor) {
        processor = commandProcessor;
    }

    String processInput(String inputLine) {
        String[] args = inputLine.split("\\|");
        String command = args[0];
        if (command.equals("port")) {
            CommunicationManager.INSTANCE.connectTo(Integer.parseInt(args[1]));
            return "connected";
        } else if (command.equals("hello")) {
            return processor.hello();
        } else if (command.equals("addWidget")) {
            return String.valueOf(processor.addWidget(args[1], Double.parseDouble(args[2]), Double.parseDouble(args[3])));
        } else {
            Logger.getLogger(CommunicationReceiver.class.getName()).log(Level.WARNING, "Unknown Command: " + inputLine);
        }
        return null;
    }

}
