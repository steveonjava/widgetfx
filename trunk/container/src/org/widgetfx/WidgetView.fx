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

import org.widgetfx.toolbar.WidgetToolbar;
import org.widgetfx.ui.Constrained;
import org.widgetfx.ui.WidgetContainer;
import java.lang.*;
import javafx.animation.*;
import javafx.scene.*;
import javafx.scene.effect.*;
import javafx.scene.input.*;
import javafx.scene.shape.*;
import javafx.scene.layout.*;
import javafx.scene.paint.*;

/**
 * @author Stephen Chin
 */
public var TOP_BORDER = 3;
public var BOTTOM_BORDER = 7;

public class WidgetView extends Group, Constrained {    
    public-init var container:WidgetContainer;
    public-init var instance:WidgetInstance;
    public-init var widget = bind instance.widget;
    
    var resizing = false;
    public-read var docking = false;
    
    var dockedParent:Group;
    var initialScreenPosX:Integer;
    var initialScreenPosY:Integer;
    
    var scale:Number = bind calculateScale();
    
    bound function calculateScale():Number {
        return if (not widget.resizable) {
            var widthScale = if (maxWidth == Constrained.UNBOUNDED) 1.0 else maxWidth / widget.width;
            var heightScale = if (maxHeight == Constrained.UNBOUNDED) 1.0 else maxHeight / widget.height;
            var scale = Math.min(widthScale, heightScale);
            return if (scale > 1) 1 else scale;
        } else {
            1.0;
        }
    }
    
    var firstRollover = true;
        
    var hasFocus:Boolean on replace {
        if (firstRollover) {
            firstRollover = false;
        } else {
            rolloverTimeline.start();
        }
    }
    
    var needsFocus:Boolean;
    
    // this is a workaround for the issue with toggle timelines that are stopped and started immediately triggering a full animation
    function requestFocus(focus:Boolean):Void {
        needsFocus = focus;
        DeferredTask {
            action: function() {
                hasFocus = needsFocus;
            }
        }
    }
    
    var rolloverOpacity = 0.0;
    var rolloverTimeline = Timeline {
        autoReverse: true, toggle: true
        keyFrames: KeyFrame {time: 500ms, values: rolloverOpacity => 1.0 tween Interpolator.EASEIN}
    }
    
    function resize() {
        if (instance.widget.resizable) {
            if (maxWidth != Constrained.UNBOUNDED) {
                instance.widget.width = maxWidth.intValue();
            }
            if (maxHeight != Constrained.UNBOUNDED) {
                instance.widget.height = maxHeight.intValue();
            }
            if (instance.widget.aspectRatio != 0) {
                var currentRatio = (instance.widget.width as Number) / instance.widget.height;
                if (currentRatio > instance.widget.aspectRatio) {
                    instance.widget.width = (instance.widget.aspectRatio * instance.widget.height).intValue();                
                } else {
                    instance.widget.height = (instance.widget.width / instance.widget.aspectRatio).intValue();
                }
            }
        }
    }
    
    override var maxWidth on replace {
        resize();
    }
    
    override var maxHeight on replace {
        resize();
    }
    
    init {
        cache = true;
        content = [
            Rectangle { // Invisible Spacer
                height: bind widget.height * scale + TOP_BORDER + BOTTOM_BORDER
                width: bind maxWidth
                fill: Color.rgb(0, 0, 0, 0.0)
            },
            Group { // Widget with DropShadow
                translateY: TOP_BORDER
                translateX: bind (maxWidth - widget.width * scale) / 2
                content: [
                    Group { // Rear Slice
                        cache: true
                        content: Group { // Drop Shadow
                            effect: bind if (resizing or container.resizing) null else DropShadow {offsetX: 2, offsetY: 2, radius: Dock.DS_RADIUS}
                            content: Group { // Clip Group
                                content: bind widget.stage.content[0]
                                clip: Rectangle {width: bind widget.width, height: bind widget.height}
                                scaleX: bind scale, scaleY: bind scale
                            }
                        }
                    },
                    Group { // Front Slices
                        cache: true
                        content: bind widget.stage.content[1..]
                        clip: Rectangle {width: bind widget.width, height: bind widget.height}
                        scaleX: bind scale, scaleY: bind scale
                    },
                ]
            },
            WidgetToolbar {
                blocksMouse: true
                translateX: bind (maxWidth + widget.width * scale) / 2
                opacity: bind rolloverOpacity
                instance: instance
                onMouseEntered: function(e) {requestFocus(true)}
                onMouseExited: function(e) {requestFocus(false)}
                onClose: function() {
                    WidgetManager.getInstance().removeWidget(instance);
                }
            },
            Group { // Drag Bar
                blocksMouse: true
                translateY: bind widget.height * scale + TOP_BORDER + BOTTOM_BORDER - 3
                content: [
                    Line {endX: bind maxWidth, stroke: Color.BLACK, strokeWidth: 1, opacity: bind Dock.getInstance().rolloverOpacity / 4},
                    Line {endX: bind maxWidth, stroke: Color.BLACK, strokeWidth: 1, opacity: bind Dock.getInstance().rolloverOpacity, translateY: 1},
                    Line {endX: bind maxWidth, stroke: Color.WHITE, strokeWidth: 1, opacity: bind Dock.getInstance().rolloverOpacity / 3, translateY: 2}
                ]
                cursor: Cursor.V_RESIZE
                var initialHeight;
                var initialY;
                onMousePressed: function(e:MouseEvent) {
                    if (widget.resizable) {
                        resizing = true;
                        initialHeight = widget.height * scale;
                        initialY = e.getStageY().intValue();
                    }
                }
                onMouseDragged: function(e:MouseEvent) {
                    if (resizing) {
                        widget.height = (initialHeight + (e.getStageY().intValue() - initialY) / scale).intValue();
                        if (widget.height < WidgetInstance.MIN_HEIGHT) {
                            widget.height = WidgetInstance.MIN_HEIGHT;
                        }
                        if (widget.aspectRatio != 0) {
                            widget.width = (widget.height * widget.aspectRatio).intValue();
                            if (widget.width > maxWidth) {
                                widget.width = maxWidth.intValue();
                                widget.height = (widget.width / widget.aspectRatio).intValue();
                            }
                        }
                    }
                }
                onMouseReleased: function(e) {
                    if (resizing) {
                        if (widget.onResize != null) {
                            widget.onResize(widget.width, widget.height);
                        }
                        instance.saveWithoutNotification();
                        resizing = false;
                    }
                }
            }
        ];
        onMousePressed = function(e:MouseEvent):Void {
            initialScreenPosX = -e.getStageX().intValue();
            initialScreenPosY = -e.getStageY().intValue();
        };
        onMouseDragged = function(e:MouseEvent):Void {
            if (not docking) {
                var xPos;
                var yPos;
                if (instance.docked) {
                    container.dragging = true;
                    var bounds = container.layout.getScreenBounds(this);
                    xPos = (bounds.x + (bounds.width - widget.width * scale) / 2 - WidgetFrame.BORDER).intValue();
                    var toolbarHeight = if (instance.widget.configuration == null) WidgetFrame.NONRESIZABLE_TOOLBAR_HEIGHT else WidgetFrame.RESIZABLE_TOOLBAR_HEIGHT;
                    yPos = bounds.y + TOP_BORDER - (WidgetFrame.BORDER + toolbarHeight);
                    instance.frame = WidgetFrame {
                        instance: instance
                        x: xPos, y: yPos
                    }
                    initialScreenPosX += xPos;
                    initialScreenPosY += yPos;
                }
                var hoverOffset = [0, 0];
                for (container in WidgetContainer.containers) {
                    var offset = container.hover(instance, e.getScreenX(), e.getScreenY(), e.getX(), e.getY(), not instance.docked);
                    if (offset != [0, 0]) {
                        hoverOffset = offset;
                    }
                }
                instance.docked = false;
                instance.frame.x = e.getStageX().intValue() + initialScreenPosX + hoverOffset[0];
                instance.frame.y = e.getStageY().intValue() + initialScreenPosY + hoverOffset[1];
            }
        };
        onMouseReleased = function(e:MouseEvent):Void {
            if (not docking and not instance.docked) {
                for (container in WidgetContainer.containers) {
                    var targetBounds = container.finishHover(instance, e.getScreenX(), e.getScreenY());
                    if (targetBounds != null) {
                        docking = true;
                        instance.frame.dock(targetBounds.x + (targetBounds.width - widget.width) / 2, targetBounds.y);
                    } else {
                        // todo - don't call onResize multiple times
                        if (instance.widget.onResize != null) {
                            instance.widget.onResize(instance.widget.width, instance.widget.height);
                        }
                    }
                }
                container.dragging = false;
                instance.saveWithoutNotification();
            }
        };
        onMouseEntered = function(e) {requestFocus(true)}
        onMouseExited = function(e) {requestFocus(false)}
    }
}
