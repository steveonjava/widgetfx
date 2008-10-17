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
import javafx.lang.*;
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
    var widget = bind instance.widget;
    
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
            if (scale > 1) 1.0 else scale;
        } else {
            1.0;
        }
    }
    
    var firstRollover = true;
        
    var hasFocus:Boolean on replace {
        if (firstRollover) {
            firstRollover = false;
        } else {
            rolloverTimeline.play();
        }
    }
    
    var needsFocus:Boolean;
    
    // this is a workaround for the issue with toggle timelines that are stopped and started immediately triggering a full animation
    function requestFocus(focus:Boolean):Void {
        needsFocus = focus;
        FX.deferAction(
            function():Void {
                hasFocus = needsFocus;
            }
        );
    }
    
    var rolloverOpacity = 0.0;
    var rolloverTimeline = Timeline {
        autoReverse: true
        keyFrames: KeyFrame {time: 500ms, values: rolloverOpacity => 1.0 tween Interpolator.EASEIN}
    }
    
    function resize() {
        if (instance.widget.resizable) {
            if (maxWidth != Constrained.UNBOUNDED) {
                instance.setWidth(maxWidth);
        System.out.println("setting width: {maxWidth}")
            }
            if (maxHeight != Constrained.UNBOUNDED) {
                instance.setHeight(maxHeight);
            }
            if (instance.widget.aspectRatio != 0) {
                var currentRatio = (instance.widget.width as Number) / instance.widget.height;
                if (currentRatio > instance.widget.aspectRatio) {
                    instance.setWidth(instance.widget.aspectRatio * instance.widget.height);                
                } else {
                    instance.setHeight(instance.widget.width / instance.widget.aspectRatio);
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
    
    function wrapContent(content:Node[]):Node[] {
        java.lang.System.out.println("wrapping content: {content[0]}, XXXXXXXXXXXXXXXXX {content[1..]}");
        return [
            Rectangle { // Invisible Spacer
                height: bind widget.height * scale + TOP_BORDER + BOTTOM_BORDER
                width: bind widget.width * scale
                fill: Color.BLUE
                //fill: Color.rgb(0, 0, 0, 0.0)
            },
            Group { // Rear Slice
                cache: true
                content: Group { // Drop Shadow
                    effect: bind if (resizing or container.resizing) null else DropShadow {offsetX: 2, offsetY: 2, radius: Dock.DS_RADIUS}
                    content: Group { // Clip Group
                        content: content[0]
                        clip: Rectangle {width: bind widget.width, height: bind widget.height}
                        scaleX: bind scale, scaleY: bind scale
                    }
                }
            },
            Group { // Front Slices
                cache: true
                content: content[1..]
                clip: Rectangle {width: bind widget.width, height: bind widget.height}
                scaleX: bind scale, scaleY: bind scale
            },
        ]
    }
    
    override var cache = true;
    
    var embeddedWidget = widget;
    
    init {
        content = [
            Rectangle { // Invisible Spacer
                height: bind widget.height * scale + TOP_BORDER + BOTTOM_BORDER
                width: bind maxWidth
                fill: Color.rgb(0, 0, 0, 0.0)
            },
            Group { // Widget with DropShadow
                translateY: TOP_BORDER
                translateX: bind (maxWidth - widget.width * scale) / 2
                cache: true
                content: Group { // Drop Shadow
                    effect: bind if (resizing or container.resizing) null else DropShadow {offsetX: 2, offsetY: 2, radius: Dock.DS_RADIUS}
                    content: Group { // Clip Group
                        content: bind embeddedWidget
                        clip: Rectangle {width: bind widget.width, height: bind widget.height}
                        scaleX: bind scale, scaleY: bind scale
                    }
                }
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
                        initialY = e.sceneY.intValue();
                    }
                }
                onMouseDragged: function(e:MouseEvent) {
                    if (resizing) {
                        instance.setHeight(initialHeight + (e.sceneY.intValue() - initialY) / scale);
                        if (widget.height < WidgetInstance.MIN_HEIGHT) {
                            instance.setHeight(WidgetInstance.MIN_HEIGHT);
                        }
                        if (widget.aspectRatio != 0) {
                            instance.setWidth(widget.height * widget.aspectRatio);
                            if (widget.width > maxWidth) {
                                instance.setWidth(maxWidth);
                                instance.setHeight(widget.width / widget.aspectRatio);
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
    }
        
    override var onMousePressed = function(e:MouseEvent):Void {
        initialScreenPosX = -e.sceneX.intValue();
        initialScreenPosY = -e.sceneY.intValue();
    };

    override var onMouseDragged = function(e:MouseEvent):Void {
        if (not docking) {
            var xPos;
            var yPos;
            if (instance.docked) {
                container.dragging = true;
                var bounds = container.layout.getScreenBounds(this);
                xPos = (bounds.x + (bounds.width - widget.width * scale) / 2 - WidgetFrame.BORDER).intValue();
                var toolbarHeight = if (instance.widget.configuration == null) WidgetFrame.NONRESIZABLE_TOOLBAR_HEIGHT else WidgetFrame.RESIZABLE_TOOLBAR_HEIGHT;
                yPos = bounds.y + TOP_BORDER - (WidgetFrame.BORDER + toolbarHeight);
                //embeddedWidget = null;
                instance.frame = WidgetFrame {
                    instance: instance
                    x: xPos, y: yPos
                }
                initialScreenPosX += xPos;
                initialScreenPosY += yPos;
            }
            var hoverOffset:Number[] = [0, 0];
//            for (container in WidgetContainer.containers) {
//                var offset = container.hover(instance, e.screenX, e.screenY, e.x, e.y, not instance.docked);
//                if (offset != [0, 0]) {
//                    hoverOffset = offset;
//                }
//            }
            instance.docked = false;
            instance.frame.x = e.sceneX.intValue() + initialScreenPosX + hoverOffset[0];
            instance.frame.y = e.sceneY.intValue() + initialScreenPosY + hoverOffset[1];
        }
    };
    
    override var onMouseReleased = function(e:MouseEvent):Void {
        if (not docking and not instance.docked) {
            for (container in WidgetContainer.containers) {
                var targetBounds = container.finishHover(instance, e.screenX, e.screenY);
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
    
    override var onMouseEntered = function(e) {requestFocus(true)}
    
    override var onMouseExited = function(e) {requestFocus(false)}
}
