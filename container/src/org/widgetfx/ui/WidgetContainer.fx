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
import javafx.application.*;
import javafx.lang.*;
import javafx.scene.*;
import org.widgetfx.*;

/**
 * @author Stephen Chin
 * @author Keith Combs
 */
public class WidgetContainer extends Group {
    
    public static attribute containers:WidgetContainer[];
    
    public attribute widgets:WidgetInstance[];
    
    public attribute dockedWidgets = bind widgets[w|w.docked];
    
    public attribute rolloverOpacity:Number;
    
    public attribute window:Window on replace {
        WidgetEventQueue.getInstance().registerInterceptor(window, EventInterceptor {
            var draggingViews:WidgetView[];
            var draggingSources:Object[];
            public function shouldIntercept(event):Boolean {
                if (event.getID() == java.awt.event.MouseEvent.MOUSE_ENTERED) {
                } else if (event.getID() == java.awt.event.MouseEvent.MOUSE_EXITED) {
                    for (view in draggingViews) {
                        view.finishDrag(event.getXOnScreen(), event.getYOnScreen());
                    }
                    draggingViews = [];
                    draggingSources = [];
                    for (view in widgetViews) {
                        view.requestFocus(false);
                    }
                } else if (event.getID() == java.awt.event.MouseEvent.MOUSE_MOVED) {
                    for (view in widgetViews) {
                        view.requestFocus(layout.getScreenBounds(view).contains(event.getLocationOnScreen()));
                    }
                }
                if (event.getID() == java.awt.event.MouseEvent.MOUSE_PRESSED and event.getButton() == java.awt.event.MouseEvent.BUTTON1) {
                    for (view in widgetViews where not view.resizing) {
                        if (view.widget.dragAnywhere and layout.getScreenBounds(view).contains(event.getLocationOnScreen())) {
                            view.prepareDrag(event.getX(), event.getY(), event.getXOnScreen(), event.getYOnScreen());
                            insert view into draggingViews;
                            insert event.getSource() into draggingSources;
                        }
                    }
                } else if (event.getID() == java.awt.event.MouseEvent.MOUSE_DRAGGED and Sequences.indexOf(draggingSources, event.getSource()) != -1) {
                    var view = draggingViews[Sequences.indexOf(draggingSources, event.getSource())];
                    if (view.resizing) {
                        delete view from draggingViews;
                        delete event.getSource() from draggingSources;
                    } else {
                        view.doDrag(event.getXOnScreen(), event.getYOnScreen());
                    }
                } else if (event.getID() == java.awt.event.MouseEvent.MOUSE_RELEASED and event.getButton() == java.awt.event.MouseEvent.BUTTON1 and Sequences.indexOf(draggingSources, event.getSource()) != -1) {
                    var view = draggingViews[Sequences.indexOf(draggingSources, event.getSource())];
                    view.finishDrag(event.getXOnScreen(), event.getYOnScreen());
                    delete view from draggingViews;
                    delete event.getSource() from draggingSources;
                }
                return false;
            }
        });
    }
    
    // if this is set, copy widget when dropped on a new container, but place the original
    // widget back in the source container
    public attribute copyOnContainerDrop:Boolean;
    
    public attribute layout:GapBox on replace {
        layout.maxWidth = width;
        layout.maxHeight = height;
        layout.content = widgetViews;
        content = [layout];
    }
    
    public attribute width:Integer on replace {
        layout.maxWidth = width;
    }
    
    public attribute height:Integer on replace {
        layout.maxHeight = height;
    }
    
    public attribute resizing:Boolean;
    
    public attribute dragging:Boolean;
    
    private attribute widgetViews:WidgetView[] = bind for (instance in dockedWidgets) createWidgetView(instance) on replace {
        layout.content = widgetViews;
    }
    
    private function createWidgetView(instance:WidgetInstance):WidgetView {
        return WidgetView {
            container: this
            instance: instance
        }
    }
    
    private attribute animateHover:Timeline;
    private attribute animatingInstance:WidgetInstance;
    private attribute animating = bind if (animateHover == null) false else animateHover.running on replace {
        animatingInstance.frame.animating = animating;
    }
    private attribute animateDocked:Boolean;
    private attribute saveUndockedWidth:Integer;
    private attribute saveUndockedHeight:Integer;
    private attribute xHoverOffset:Integer on replace oldValue {
        animatingInstance.frame.x += xHoverOffset - oldValue;
    }
    private attribute yHoverOffset:Integer on replace oldValue {
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
        var newXHoverOffset = localX - localX * newWidth / instance.widget.stage.width;
        var newYHoverOffset = localY - localY * newHeight / instance.widget.stage.height;
        animateHover = Timeline {
            autoReverse: true, toggle: true
            keyFrames: KeyFrame {
                time: 300ms
                values: [
                    if (newWidth > 0) {[
                        instance.widget.stage.width => newWidth tween Interpolator.EASEBOTH,
                        xHoverOffset => newXHoverOffset tween Interpolator.EASEBOTH
                    ]} else {
                        []
                    },
                    if (newHeight > 0) {[
                        instance.widget.stage.height => newHeight tween Interpolator.EASEBOTH,
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
        if (layout.containsScreenXY(screenX, screenY)) {
            var dockedHeight = if (instance.dockedHeight == 0) instance.widget.stage.height else instance.dockedHeight;
            layout.setGap(screenX, screenY, dockedHeight + Dock.DS_RADIUS * 2 + 2, animate);
            if (animateHover != null and not animateDocked) {
                animateDocked = true;
                animateHover.start();
            }
        } else {
            layout.clearGap(animate);
            if (animateHover != null and animateDocked) {
                animateDocked = false;
                animateHover.start();
            }
        }
        return [xHoverOffset, yHoverOffset];
    }
    
    public function finishHover(instance:WidgetInstance, screenX:Integer, screenY:Integer):java.awt.Rectangle {
        if (layout.containsScreenXY(screenX, screenY)) {
            animateHover.stop();
            animateHover = null;
            instance.undockedWidth = saveUndockedWidth;
            instance.undockedHeight = saveUndockedHeight;
            return layout.getGapScreenBounds();
        } else {
            if (animateHover != null and animateDocked) {
                animateDocked = false;
                animateHover.start();
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
