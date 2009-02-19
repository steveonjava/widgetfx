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
