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
import javafx.geometry.*;
import javafx.scene.*;
import javafx.scene.layout.*;
import javafx.util.*;
import org.widgetfx.*;
import org.widgetfx.layout.*;
import java.util.Properties;

import java.awt.AWTEvent;
import java.awt.Toolkit;
import java.awt.event.AWTEventListener;
import java.lang.Void;

import java.awt.Component;
import javax.swing.SwingUtilities;

import javafx.scene.input.MouseEvent;

import javafx.scene.input.MouseButton;

/**
 * @author Stephen Chin
 * @author Keith Combs
 */
public class WidgetContainer extends Container, WidgetDragListener {
    
    public var widgets:WidgetInstance[];
    
    public-read var dockedWidgets = bind widgets[w|w.docked and w.initialized];

    public var rolloverOpacity:Number;

    public-read var widgetDragging = false;
    
    public var window:Window on replace {
        Toolkit.getDefaultToolkit().addAWTEventListener(AWTEventListener {
            override function eventDispatched(event:AWTEvent):Void {
                if (event.getSource() instanceof Component and not SwingUtilities.isDescendingFrom(event.getSource() as Component, window)) {
                    return;
                }
                if (event.getID() == java.awt.event.MouseEvent.MOUSE_EXITED) {
                    for (view in widgetViews) {
                        view.widgetHover = false;
                    }
                } else if (event.getID() == java.awt.event.MouseEvent.MOUSE_MOVED) {
                    for (view in widgetViews) {
                        var screenLoc = (event as java.awt.event.MouseEvent).getLocationOnScreen();
                        view.widgetHover = gapBox.getScreenBounds(view).contains(screenLoc.x, screenLoc.y);
                    }
                }
            }
        }, AWTEvent.MOUSE_EVENT_MASK + AWTEvent.MOUSE_MOTION_EVENT_MASK);
    }
    
    // if this is set, copy widget when dropped on a new container, but place the original
    // widget back in the source container
    public-init var copyOnContainerDrop:Boolean;
    
    public-init var gapBox:GapBox on replace {
        gapBox.maxWidth = width;
        gapBox.maxHeight = height;
        gapBox.content = widgetViews;
        content = [gapBox];
    }
    
    override var width on replace {
        gapBox.maxWidth = width;
    }
    
    override var height on replace {
        gapBox.maxHeight = height;
    }
    
    public var drawShadows:Boolean;
    
    public var dragging:Boolean;

    public var draggingView:WidgetView;
    
    var widgetViews:WidgetView[] = bind for (instance in dockedWidgets) createWidgetView(instance) on replace {
        gapBox.content = widgetViews;
    }

    public function startDrag(view:WidgetView, e:MouseEvent):Void {
        if (e.button == MouseButton.PRIMARY) {
            view.prepareDrag(e.x, e.y, e.screenX, e.screenY);
            draggingView = view;
        }
    }

    override var onMouseDragged = function(e:MouseEvent):Void {
        draggingView.doDrag(e.screenX, e.screenY);
    };

    override var onMouseReleased = function(e:MouseEvent):Void {
        if (e.button == MouseButton.PRIMARY) {
            draggingView.finishDrag(e.screenX, e.screenY);
        }
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
        if (showing and gapBox.containsScreenXY(screenX, screenY)) {
            gapBox.setGap(screenX, screenY, dockedHeight + DockDialog.DS_RADIUS * 2 + 2, true);
            return gapBox.getGapScreenBounds();
        } else {
            gapBox.clearGap(true);
            return null;
        }
    }

    override function finishHover(instance:WidgetInstance, screenX:Number, screenY:Number):Rectangle2D {
        widgetDragging = false;
        def showing = visible and scene != null;
        if ((showing and copyOnContainerDrop)
            or (showing and gapBox.containsScreenXY(screenX, screenY))) {
            return gapBox.getGapScreenBounds();
        } else {
            // todo - delete widget from container (and maybe add it to a list of undocked widgets)
            // delete instance from widgets;
            gapBox.clearGap(false);
            gapBox.requestLayout();
            return null;
        }
    }

    override function finishHover(jnlpUrl:String, screenX:Number, screenY:Number, properties:Properties):Rectangle2D {
        widgetDragging = false;
        def showing = visible and scene != null;
        if (showing and gapBox.containsScreenXY(screenX, screenY) and not WidgetManager.getInstance().hasWidget(jnlpUrl, properties)) {
            FX.deferAction(function():Void {
                var instance = WidgetManager.getInstance().getWidget(jnlpUrl, properties, function(instance:WidgetInstance) {
                    dockAfterHover(instance);
                });
            });
            return gapBox.getGapScreenBounds();
        } else {
            gapBox.clearGap(false);
            gapBox.requestLayout();
            return null;
        }
    }
    
    public function dockAfterHover(instance:WidgetInstance) {
        delete instance from widgets;
        instance.dock();
        if (gapBox.getGapIndex() < 0 or gapBox.getGapIndex() >= dockedWidgets.size()) {
            insert instance into widgets;
        } else {
            var index = Sequences.indexOf(widgets, dockedWidgets[gapBox.getGapIndex()]);
            insert instance before widgets[index];
        }
        gapBox.clearGap(false);
        gapBox.requestLayout();
    }
}
