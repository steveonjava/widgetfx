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
package org.widgetfx.ui;

import org.widgetfx.*;
import java.awt.AWTEvent;
import java.awt.Component;
import java.awt.EventQueue;
import java.awt.Toolkit;
import java.awt.event.MouseEvent;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
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
    
    private Map<Component, List<EventInterceptor>> interceptors = new HashMap<Component, List<EventInterceptor>>();

    private WidgetEventQueue() {
        SwingUtilities.invokeLater(new Runnable() {
            @Override
            public void run() {
                Toolkit.getDefaultToolkit().getSystemEventQueue().push(WidgetEventQueue.this);
            }
        });
    }
    
    public void registerInterceptor(final Component parent, final EventInterceptor interceptor) {
        SwingUtilities.invokeLater(new Runnable() {
            @Override
            public void run() {
                List<EventInterceptor> interceptorList;
                if (interceptors.containsKey(parent)) {
                    interceptorList = interceptors.get(parent);
                } else {
                    interceptorList = new ArrayList<EventInterceptor>();
                    interceptors.put(parent, interceptorList);
                }
                interceptorList.add(interceptor);
            }
        });
    }
    
    public void removeInterceptor(final Component parent) {
        SwingUtilities.invokeLater(new Runnable() {
            @Override
            public void run() {
                List<EventInterceptor> interceptorList = interceptors.get(parent);
                if (interceptorList != null) {
                    interceptorList.remove(parent);
                    if (interceptorList.isEmpty()) {
                        interceptors.remove(parent);
                    }
                }
            }
        });
    }

    @Override
    protected void dispatchEvent(AWTEvent awtEvent) {
        if (awtEvent instanceof MouseEvent) {
            MouseEvent event = (MouseEvent) awtEvent;
            Object source = event.getSource();
            if (source instanceof Component) {
                Component component = (Component) source;
                for (Map.Entry<Component, List<EventInterceptor>> interceptorEntry: interceptors.entrySet()) {
                    if (component.equals(interceptorEntry.getKey()) || SwingUtilities.isDescendingFrom(component, interceptorEntry.getKey())) {
                        for (EventInterceptor interceptor : interceptorEntry.getValue()) {
                            if (interceptor.shouldIntercept(event)) {
                                return;
                            }
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
