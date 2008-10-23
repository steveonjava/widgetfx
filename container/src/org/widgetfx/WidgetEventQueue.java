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
package org.widgetfx;

import java.awt.AWTEvent;
import java.awt.Component;
import java.awt.EventQueue;
import java.awt.Toolkit;
import java.awt.event.MouseEvent;
import java.util.HashMap;
import java.util.Map;
import javax.swing.SwingUtilities;

/**
 * @author Stephen Chin
 */
public class WidgetEventQueue extends EventQueue {

    private static WidgetEventQueue instance;

    public static WidgetEventQueue getInstance() {
        if (instance == null) {
            instance = new WidgetEventQueue();
        }
        return instance;
    }
    
    private Map<Component, EventInterceptor> interceptors = new HashMap<Component, EventInterceptor>();

    private WidgetEventQueue() {
        SwingUtilities.invokeLater(new Runnable() {
            @Override
            public void run() {
                Toolkit.getDefaultToolkit().getSystemEventQueue().push(WidgetEventQueue.this);
            }
        });
    }
    
    public void registerInterceptor(Component parent, EventInterceptor interceptor) {
        interceptors.put(parent, interceptor);
    }
    
    public void removeInterceptor(Component parent) {
        interceptors.remove(parent);
    }

    @Override
    protected void dispatchEvent(AWTEvent awtEvent) {
        if (awtEvent instanceof MouseEvent) {
            MouseEvent event = (MouseEvent) awtEvent;
//            // todo - remove this when the scene graph event queue bug with dragging is fixed
//            if (event.getX() == Integer.MAX_VALUE || event.getX() == Integer.MIN_VALUE) {
//                System.out.println("fixed a bad event!");
//                return;
//            }
//            if (event.getY() == Integer.MAX_VALUE || event.getY() == Integer.MIN_VALUE) {
//                System.out.println("fixed a bad event!");
//                return;
//            }
            Object source = event.getSource();
            if (source instanceof Component) {
                Component component = (Component) source;
                for (Map.Entry<Component, EventInterceptor> interceptor: interceptors.entrySet()) {
                    if (component.equals(interceptor.getKey())) {
                        if (interceptor.getValue().shouldIntercept(event)) {
                            return;
                        }
                    }
                }
            }
        }
        super.dispatchEvent(awtEvent);
    }

    public Object clone() throws CloneNotSupportedException {
        throw new CloneNotSupportedException();
    }
}
