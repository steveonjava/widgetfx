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
import javafx.animation.*;
import javafx.input.*;
import javafx.lang.DeferredTask;
import javafx.scene.*;
import javafx.scene.effect.*;
import javafx.scene.geometry.*;
import javafx.scene.layout.*;
import javafx.scene.paint.*;

/**
 * @author Stephen Chin
 */
public class WidgetView extends Group, Constrained {
    public static attribute TOP_BORDER = 3;
    public static attribute BOTTOM_BORDER = 7;
    
    public attribute container:WidgetContainer;
    public attribute instance:WidgetInstance;
    private attribute widget = bind instance.widget;
    
    private attribute resizing = false;
    public attribute docking = false;
    
    private attribute dockedParent:Group;
    private attribute initialScreenPosX:Integer;
    private attribute initialScreenPosY:Integer;
    
    private attribute scale:Number = bind calculateScale();
    
    private bound function calculateScale():Number {
        return if (widget.resizable or widget.stage.width < maxWidth) {
            1.0;
        } else {
            maxWidth / widget.stage.width;
        }
    }
    
    private attribute firstRollover = true;
        
    private attribute hasFocus:Boolean on replace {
        if (firstRollover) {
            firstRollover = false;
        } else {
            rolloverTimeline.start();
        }
    }
    
    private attribute needsFocus:Boolean;
    
    // this is a workaround for the issue with toggle timelines that are stopped and started immediately triggering a full animation
    private function requestFocus(focus:Boolean):Void {
        needsFocus = focus;
        DeferredTask {
            action: function() {
                hasFocus = needsFocus;
            }
        }
    }
    
    private attribute rolloverOpacity = 0.0;
    private attribute rolloverTimeline = Timeline {
        autoReverse: true, toggle: true
        keyFrames: KeyFrame {time: 500ms, values: rolloverOpacity => 1.0 tween Interpolator.EASEIN}
    }
    
    override attribute maxWidth on replace {
        if (instance.widget.resizable) {
            instance.widget.stage.width = maxWidth.intValue();
            if (instance.widget.aspectRatio != 0) {
                instance.widget.stage.height = (instance.widget.stage.width / instance.widget.aspectRatio).intValue();
            }
        }
    }
    
    init {
        cache = true;
        content = [
            Rectangle { // Invisible Spacer
                height: bind widget.stage.height * scale + TOP_BORDER + BOTTOM_BORDER
                width: bind maxWidth
                fill: Color.rgb(0, 0, 0, 0.0)
            },
            Group { // Widget with DropShadow
                translateY: TOP_BORDER
                translateX: bind (maxWidth - widget.stage.width * scale) / 2
                content: [
                    Group { // Rear Slice
                        cache: true
                        content: Group { // Drop Shadow
                            effect: bind if (resizing or container.resizing) null else DropShadow {offsetX: 2, offsetY: 2, radius: Dock.DS_RADIUS}
                            content: Group { // Clip Group
                                content: bind widget.stage.content[0]
                                clip: Rectangle {width: bind widget.stage.width, height: bind widget.stage.height}
                                scaleX: bind scale, scaleY: bind scale
                            }
                        }
                    },
                    Group { // Front Slices
                        cache: true
                        content: bind widget.stage.content[1..]
                        clip: Rectangle {width: bind widget.stage.width, height: bind widget.stage.height}
                        scaleX: bind scale, scaleY: bind scale
                    },
                ]
            },
            WidgetToolbar {
                blocksMouse: true
                translateX: bind (maxWidth + widget.stage.width * scale) / 2
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
                translateY: bind widget.stage.height * scale + TOP_BORDER + BOTTOM_BORDER - 3
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
                        initialHeight = widget.stage.height * scale;
                        initialY = e.getStageY().intValue();
                    }
                }
                onMouseDragged: function(e:MouseEvent) {
                    if (resizing) {
                        widget.stage.height = (initialHeight + (e.getStageY().intValue() - initialY) / scale).intValue();
                        if (widget.stage.height < WidgetInstance.MIN_HEIGHT) {
                            widget.stage.height = WidgetInstance.MIN_HEIGHT;
                        }
                        if (widget.aspectRatio != 0) {
                            widget.stage.width = (widget.stage.height * widget.aspectRatio).intValue();
                            if (widget.stage.width > maxWidth) {
                                widget.stage.width = maxWidth.intValue();
                                widget.stage.height = (widget.stage.width / widget.aspectRatio).intValue();
                            }
                        }
                    }
                }
                onMouseReleased: function(e) {
                    if (resizing) {
                        if (widget.onResize != null) {
                            widget.onResize(widget.stage.width, widget.stage.height);
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
                    xPos = (bounds.x + (bounds.width - widget.stage.width * scale) / 2 - WidgetFrame.BORDER).intValue();
                    var toolbarHeight = if (instance.widget.configuration == null) WidgetFrame.NONRESIZABLE_TOOLBAR_HEIGHT else WidgetFrame.RESIZABLE_TOOLBAR_HEIGHT;
                    yPos = bounds.y + TOP_BORDER - (WidgetFrame.BORDER + toolbarHeight);
                    instance.frame = WidgetFrame {
                        instance: instance
                        x: xPos, y: yPos
                    }
                    initialScreenPosX += xPos;
                    initialScreenPosY += yPos;
                }
                var hoverOffset:Integer[];
                for (container in WidgetContainer.containers) {
                    // todo - don't let the last container win...
                    hoverOffset = container.hover(instance, e.getScreenX().intValue(), e.getScreenY().intValue(), e.getX(), e.getY(), not instance.docked);
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
                        instance.frame.dock(targetBounds.x + (targetBounds.width - widget.stage.width) / 2, targetBounds.y);
                    } else {
                        // todo - don't call onResize multiple times
                        if (instance.widget.onResize != null) {
                            instance.widget.onResize(instance.widget.stage.width, instance.widget.stage.height);
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
