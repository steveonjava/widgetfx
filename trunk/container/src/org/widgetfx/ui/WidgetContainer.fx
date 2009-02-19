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

import java.awt.Window;
import java.lang.*;
import java.net.URL;
import javafx.animation.*;
import javafx.geometry.*;
import javafx.scene.*;
import javafx.scene.layout.*;
import javafx.util.*;
import javax.jnlp.*;
import javax.swing.JPanel;
import org.widgetfx.*;
import org.widgetfx.communication.*;
import org.widgetfx.layout.*;
import java.util.Properties;

/**
 * @author Stephen Chin
 * @author Keith Combs
 */
public class WidgetContainer extends Container, WidgetDragListener {
    
    public var widgets:WidgetInstance[];
    
    public-read var dockedWidgets = bind widgets[w|w.docked];
    
    public var rolloverOpacity:Number;

    public-read var widgetDragging = false;
    
    public var window:Window on replace {
        WidgetEventQueue.getInstance().registerInterceptor(window, EventInterceptor {
            override function shouldIntercept(event):Boolean {
                if (event.getID() == java.awt.event.MouseEvent.MOUSE_EXITED) {
                    for (view in widgetViews) {
                        view.widgetHover = false;
                    }
                } else if (event.getID() == java.awt.event.MouseEvent.MOUSE_MOVED) {
                    for (view in widgetViews) {
                        var screenLoc = event.getLocationOnScreen();
                        view.widgetHover = layout.getScreenBounds(view).contains(screenLoc.x, screenLoc.y);
                    }
                }
                return false;
            }
        });
    }
    
    // if this is set, copy widget when dropped on a new container, but place the original
    // widget back in the source container
    public-init var copyOnContainerDrop:Boolean;
    
    public-init var layout:GapBox on replace {
        layout.maxWidth = width;
        layout.maxHeight = height;
        layout.content = widgetViews;
        content = [layout];
    }
    
    override var width on replace {
        layout.maxWidth = width;
    }
    
    override var height on replace {
        layout.maxHeight = height;
    }
    
    public var drawShadows:Boolean;
    
    public var dragging:Boolean;
    
    var widgetViews:WidgetView[] = bind for (instance in dockedWidgets) createWidgetView(instance) on replace {
        layout.content = widgetViews;
    }
    
    function createWidgetView(instance:WidgetInstance):WidgetView {
        return WidgetView {
            container: this
            instance: instance
        }
    }
    
    init {
        insert this into WidgetDragListener.dragListeners;
    }

    override function hover(dockedHeight:Number, screenX:Number, screenY:Number):Rectangle2D {
        widgetDragging = true;
        def showing = visible and scene != null;
        if (showing and layout.containsScreenXY(screenX, screenY)) {
            layout.setGap(screenX, screenY, dockedHeight + Dock.DS_RADIUS * 2 + 2, true);
            return layout.getGapScreenBounds();
        } else {
            layout.clearGap(true);
            return null;
        }
    }

    override function finishHover(instance:WidgetInstance, screenX:Number, screenY:Number):Rectangle2D {
        widgetDragging = false;
        def showing = visible and scene != null;
        if ((showing and copyOnContainerDrop)
            or (showing and layout.containsScreenXY(screenX, screenY))) {
            return layout.getGapScreenBounds();
        } else {
            // todo - delete widget from container (and maybe add it to a list of undocked widgets)
            // delete instance from widgets;
            layout.clearGap(false);
            layout.doLayout();
            return null;
        }
    }

    override function finishHover(jnlpUrl:String, screenX:Number, screenY:Number, properties:Properties):Rectangle2D {
        widgetDragging = false;
        def showing = visible and scene != null;
        if (showing and layout.containsScreenXY(screenX, screenY) and not WidgetManager.getInstance().hasWidget(jnlpUrl, properties)) {
            FX.deferAction(function():Void {
                var instance = WidgetManager.getInstance().getWidget(jnlpUrl, properties);
                dockAfterHover(instance);
            });
            return layout.getGapScreenBounds();
        } else {
            layout.clearGap(false);
            layout.doLayout();
            return null;
        }
    }
    
    public function dockAfterHover(instance:WidgetInstance) {
        delete instance from widgets;
        instance.dock();
        if (layout.getGapIndex() < 0 or layout.getGapIndex() >= dockedWidgets.size()) {
            insert instance into widgets;
        } else {
            var index = Sequences.indexOf(widgets, dockedWidgets[layout.getGapIndex()]);
            insert instance before widgets[index];
        }
        layout.clearGap(false);
        layout.doLayout();
    }
}
