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
import org.widgetfx.communication.*;
import javafx.geometry.*;
import javafx.animation.*;
import java.net.URLEncoder;

/**
 * @author Stephen Chin
 */
public abstract class DragContainer {
    
    public-init var instance:WidgetInstance;
    
    protected var widget = bind instance.widget;
    
    public var dragging = false;
    
    public var docking = false;

    public var hoverContainer = false;
    
    var needsInitialXY = false;
    
    protected var initialX:Number;
    
    protected var initialY:Number;
    
    protected var initialScreenX:Number;
    
    protected var initialScreenY:Number;
    
    var moved = false;

    // todo - refactor this timeline stuff (can be simplified now that it is in the DragContainer)
    var animateHover:Timeline;
    var animatingInstance:WidgetInstance;
    public var animating = bind if (animateHover == null) false else animateHover.running;
    var animateDocked:Boolean;
    var saveDocked:Boolean;
    var saveWidth:Number;
    var saveHeight:Number;
    var saveUndockedWidth:Number;
    var saveUndockedHeight:Number;
    var xHoverOffset:Number on replace oldValue {
        if (animatingInstance != null) {
            animatingInstance.frame.x += xHoverOffset - oldValue;
        }
    }
    var yHoverOffset:Number on replace oldValue {
        if (animatingInstance != null) {
            animatingInstance.frame.y += yHoverOffset - oldValue;
        }
    }

    public function setupHoverAnimation(instance:WidgetInstance, localX:Integer, localY:Integer):Void {
        animatingInstance = null; // prevent trigger from firing
        xHoverOffset = 0;
        yHoverOffset = 0;
        animatingInstance = instance;
        saveDocked = instance.docked;
        saveWidth = instance.widget.width;
        saveHeight = instance.widget.height;
        saveUndockedWidth = instance.undockedWidth;
        saveUndockedHeight = instance.undockedHeight;
        var newWidth = if (instance.docked) instance.undockedWidth else instance.dockedWidth;
        var newHeight = if (instance.docked) instance.undockedHeight else instance.dockedHeight;
        var newXHoverOffset = localX - localX * newWidth / instance.widget.width;
        var newYHoverOffset = localY - localY * newHeight / instance.widget.height;
        var width = instance.widget.width on replace {
            animatingInstance.setWidth(width);
        }
        var height = instance.widget.height on replace {
            animatingInstance.setHeight(height);
        }
        animateHover = Timeline {
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
    
    public function prepareDrag(dragX:Number, dragY:Number, screenX:Integer, screenY:Integer) {
        dragging = true;
        moved = false;
        needsInitialXY = true;
        initialScreenX = screenX;
        initialScreenY = screenY;
        hoverContainer = false;
        setupHoverAnimation(instance, dragX, dragY);
    }
    
    public function doDrag(screenX:Number, screenY:Number) {
        if (not docking and dragging) {
            moved = true;
            var hoverBounds:Rectangle2D = null;
            var dockedHeight = if (instance.dockedHeight == 0) instance.widget.height else instance.dockedHeight;
            for (dragListener in WidgetDragListener.dragListeners) {
                var bounds = dragListener.hover(dockedHeight, screenX, screenY);
                if (bounds != null) {
                    hoverBounds = bounds;
                }
            }
            var responses = CommunicationManager.INSTANCE.broadcast("hover", ["{dockedHeight}", "{screenX}", "{screenY}"]);
            var hover = hoverBounds != null;
            // todo harvest rectangle responses
            for (response in responses) {
                if (not response.equals("null")) {
                    hover = true;
                }
            }
            hoverContainer = hover;
            if (hover) {
                if (animateHover != null and not animateDocked) {
                    animateDocked = true;
                    animateHover.rate = if (saveDocked) -1 else 1;
                    animateHover.play();
                }
            } else {
                if (animateHover != null and animateDocked) {
                    animateDocked = false;
                    animateHover.rate = if (saveDocked) 1 else -1;
                    animateHover.play();
                }
            }
            if (needsInitialXY) { // wait until the last moment to do this so the subclass can position the frame
                needsInitialXY = false;
                initialX = instance.frame.x;
                initialY = instance.frame.y;
            }
            instance.frame.x = initialX + screenX - initialScreenX + xHoverOffset;
            instance.frame.y = initialY + screenY - initialScreenY + yHoverOffset;
        }
    }
    
    public function finishDrag(screenX:Number, screenY:Number) {
        hoverContainer = false;
        if (moved and not docking) {
            moved = false;
            var dropBounds:Rectangle2D = null;
            var propertyString = instance.getPropertyString(true);
            var responses = CommunicationManager.INSTANCE.broadcast("finishHover", [instance.jnlpUrl, "{screenX}", "{screenY}", URLEncoder.encode(propertyString, "UTF-8")]);
            var remoteHover = false;
            // todo harvest rectangle responses
            for (response in responses) {
                if (not response.equals("null")) {
                    remoteHover = true;
                }
            }
            for (dragListener in WidgetDragListener.dragListeners) {
                var targetBounds = if (remoteHover) {
                    var dockedHeight = if (instance.dockedHeight == 0) instance.widget.height else instance.dockedHeight;
                    dragListener.hover(dockedHeight, initialScreenX, initialScreenY);
                    dragListener.finishHover(instance, initialScreenX, initialScreenY);
                } else {
                    dragListener.finishHover(instance, screenX, screenY);
                }
                dragComplete(dragListener, targetBounds);
                if (targetBounds != null) {
                    dropBounds = targetBounds;
                }
            }
            var localHover = dropBounds != null;
            if (localHover) {
                animateHover.stop();
                animateHover = null;
                instance.undockedWidth = saveUndockedWidth;
                instance.undockedHeight = saveUndockedHeight;
            } else if (remoteHover) {
                animateHover.stop();
                animateHover = null;
                instance.setWidth(saveWidth);
                instance.setHeight(saveHeight);
                instance.frame.x = initialX;
                instance.frame.y = initialY;

            } else {
                if (animateHover != null and animateDocked) {
                    animateDocked = false;
                    animateHover.rate = if (saveDocked) -1 else 1;
                    animateHover.play();
                }
                animateHover = null;
            }
            instance.saveWithoutNotification();
        }
        dragging = false;
    }
    
    protected abstract function dragComplete(dragListener:WidgetDragListener, targetBounds:Rectangle2D):Void;
}
