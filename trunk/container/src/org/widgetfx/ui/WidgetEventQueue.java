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
