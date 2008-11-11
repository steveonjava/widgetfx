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
import javafx.animation.*;
import javafx.geometry.*;
import javafx.scene.*;
import javafx.util.*;
import javax.swing.JPanel;
import javafx.scene.layout.*;
import org.widgetfx.*;

/**
 * @author Stephen Chin
 * @author Keith Combs
 */
public var containers:WidgetContainer[];

public class WidgetContainer extends Container {
    
    public var widgets:WidgetInstance[];
    
    public-read var dockedWidgets = bind widgets[w|w.docked];
    
    public var rolloverOpacity:Number;
    
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
    
    public var resizing:Boolean;
    
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
    
    var animateHover:Timeline;
    var animatingInstance:WidgetInstance;
    var animating = bind if (animateHover == null) false else animateHover.running on replace {
        animatingInstance.frame.animating = animating;
    }
    var animateDocked:Boolean;
    var saveUndockedWidth:Number;
    var saveUndockedHeight:Number;
    var xHoverOffset:Number on replace oldValue {
        animatingInstance.frame.x += xHoverOffset - oldValue;
    }
    var yHoverOffset:Number on replace oldValue {
        animatingInstance.frame.y += yHoverOffset - oldValue;
    }
    
    init {
        insert this into containers;
    }
    
    public function setupHoverAnimation(instance:WidgetInstance, localX:Integer, localY:Integer):Void {
        animatingInstance = instance;
        xHoverOffset = 0;
        yHoverOffset = 0;
        saveUndockedWidth = instance.undockedWidth;
        saveUndockedHeight = instance.undockedHeight;
        var newWidth = if (instance.docked) instance.undockedWidth else instance.dockedWidth;
        var newHeight = if (instance.docked) instance.undockedHeight else instance.dockedHeight;
        var newXHoverOffset = localX - localX * newWidth / instance.widget.width;
        var newYHoverOffset = localY - localY * newHeight / instance.widget.height;
		// todo:merge - fix indentation
            var width = instance.widget.width on replace {
                animatingInstance.setWidth(width);
            }
            var height = instance.widget.height on replace {
                animatingInstance.setHeight(height);
            }
            animateHover = Timeline {
                autoReverse: true
                keyFrames: KeyFrame {
                    time: 300ms
                    values: [
                        if (newWidth > 0) {[
                            width => newWidth tween Interpolator.EASEBOTH,
                            xHoverOffset => newXHoverOffset tween Interpolator.EASEBOTH
                        ]} else {
                            []
                        },
                        if (newHeight > 0) {[
                            height => newHeight tween Interpolator.EASEBOTH,
                            yHoverOffset => newYHoverOffset tween Interpolator.EASEBOTH
                        ]} else {
                            []
                        }
                    ]
                }
            }
            animateDocked = instance.docked;
        }
    
    public function prepareHover(instance:WidgetInstance, localX:Integer, localY:Integer):Void {
        setupHoverAnimation(instance, localX, localY);
    }
    
    public function hover(instance:WidgetInstance, screenX:Integer, screenY:Integer, animate:Boolean) {
        if (visible and layout.containsScreenXY(screenX, screenY)) {
            var dockedHeight = if (instance.dockedHeight == 0) instance.widget.height else instance.dockedHeight;
            layout.setGap(screenX, screenY, dockedHeight + Dock.DS_RADIUS * 2 + 2, animate);
            if (animateHover != null and not animateDocked) {
                animateDocked = true;
                animateHover.play();
            }
        } else {
            layout.clearGap(animate);
            if (animateHover != null and animateDocked) {
                animateDocked = false;
                animateHover.play();
            }
        }
        return [xHoverOffset, yHoverOffset];
    }
    
    public function finishHover(instance:WidgetInstance, screenX:Integer, screenY:Integer):Rectangle2D {
        if (visible and layout.containsScreenXY(screenX, screenY)) {
            animateHover.stop();
            animateHover = null;
            instance.undockedWidth = saveUndockedWidth;
            instance.undockedHeight = saveUndockedHeight;
            return layout.getGapScreenBounds();
        } else {
            if (animateHover != null and animateDocked) {
                animateDocked = false;
                animateHover.play();
            }
            animateHover = null;
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
