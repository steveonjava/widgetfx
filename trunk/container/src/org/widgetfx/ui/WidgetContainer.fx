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
        // todo - don't animate the widget going back
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

    override function finishHover(jnlpUrl:String, screenX:Number, screenY:Number):Rectangle2D {
        widgetDragging = false;
        def showing = visible and scene != null;
        if (showing and layout.containsScreenXY(screenX, screenY) and not WidgetManager.getInstance().hasWidget(jnlpUrl)) {
            FX.deferAction(function():Void {
                var instance = WidgetManager.getInstance().getWidget(jnlpUrl);
                insert instance into widgets;
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
