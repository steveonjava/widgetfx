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

 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
package org.widgetfx;
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
public class WidgetView extends Group {
    public static attribute TOP_BORDER = 3;
    public static attribute BOTTOM_BORDER = 7;
    
    public attribute sidebar:Sidebar;
    public attribute instance:WidgetInstance;
    private attribute widget = bind instance.widget;
    
    private attribute resizing = false;
    public attribute docking = false;
    
    private attribute dockedParent:Group;
    private attribute lastScreenPosX:Integer;
    private attribute lastScreenPosY:Integer;
    
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
        keyFrames: KeyFrame {time: 1s, values: rolloverOpacity => 1.0 tween Interpolator.EASEBOTH}
    }
    
    init {
        cache = true;
        content = [
            Rectangle { // Invisible Spacer
                height: bind widget.stage.height + TOP_BORDER + BOTTOM_BORDER
                width: bind sidebar.width
                fill: Color.rgb(0, 0, 0, 0.0)
            },
            Group { // Widget with DropShadow
                translateY: TOP_BORDER
                effect: bind if (resizing or sidebar.resizing) null else DropShadow {offsetX: 2, offsetY: 2, radius: Sidebar.DS_RADIUS}
                content: Group {
                    translateX: Sidebar.BORDER
                    content: widget.stage.content
                    clip: Rectangle {width: bind widget.stage.width, height: bind widget.stage.height}
                    horizontalAlignment: HorizontalAlignment.CENTER
                    translateX: bind sidebar.width / 2
                }
            },
            WidgetToolbar {
                blocksMouse: true
                translateX: bind (sidebar.width + widget.stage.width) / 2
                horizontalAlignment: HorizontalAlignment.RIGHT
                opacity: bind rolloverOpacity
                instance: instance
                onMouseEntered: function(e) {requestFocus(true)}
                onMouseExited: function(e) {requestFocus(false)}
            },
            Group { // Drag Bar
                blocksMouse: true
                translateX: Sidebar.BORDER
                translateY: bind widget.stage.height + TOP_BORDER + BOTTOM_BORDER - 3
                content: [
                    Line {endX: bind sidebar.width - Sidebar.BORDER * 2, stroke: Color.BLACK, strokeWidth: 1, opacity: bind sidebar.rolloverOpacity / 4},
                    Line {endX: bind sidebar.width - Sidebar.BORDER * 2, stroke: Color.BLACK, strokeWidth: 1, opacity: bind sidebar.rolloverOpacity, translateY: 1},
                    Line {endX: bind sidebar.width - Sidebar.BORDER * 2, stroke: Color.WHITE, strokeWidth: 1, opacity: bind sidebar.rolloverOpacity / 3, translateY: 2}
                ]
                cursor: Cursor.V_RESIZE
                var initialHeight;
                var initialY;
                onMousePressed: function(e:MouseEvent) {
                    if (widget.resizable) {
                        resizing = true;
                        initialHeight = widget.stage.height;
                        initialY = e.getStageY().intValue();
                    }
                }
                onMouseDragged: function(e:MouseEvent) {
                    if (resizing) {
                        widget.stage.height = initialHeight + e.getStageY().intValue() - initialY;
                        if (widget.stage.height < WidgetFrame.MIN_SIZE) {
                            widget.stage.height = WidgetFrame.MIN_SIZE;
                        }
                        if (widget.aspectRatio != 0) {
                            widget.stage.width = (widget.stage.height * widget.aspectRatio).intValue();
                            if (widget.stage.width > sidebar.width - Sidebar.BORDER * 2) {
                                widget.stage.width = sidebar.width - Sidebar.BORDER * 2;
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
            lastScreenPosX = e.getStageX().intValue();
            lastScreenPosY = e.getStageY().intValue();
        };
        onMouseDragged = function(e:MouseEvent):Void {
            if (not docking) {
                instance.frame.x += e.getStageX().intValue() - lastScreenPosX;
                instance.frame.y += e.getStageY().intValue() - lastScreenPosY;
                lastScreenPosX = e.getStageX().intValue();
                lastScreenPosY = e.getStageY().intValue();
                if (instance.docked) {
                    sidebar.dragging = true;
                    var xPos = sidebar.x + (sidebar.width - widget.stage.width) / 2 - WidgetFrame.BORDER;
                    var toolbarHeight = if (instance.widget.configuration == null) WidgetFrame.NONRESIZABLE_TOOLBAR_HEIGHT else WidgetFrame.RESIZABLE_TOOLBAR_HEIGHT;
                    var yPos = sidebar.y + e.getStageY().intValue() - e.getY().intValue() + TOP_BORDER - (WidgetFrame.BORDER + toolbarHeight) - 1;
                    instance.frame = WidgetFrame {
                        instance: instance
                        x: xPos, y: yPos
                    }
                    sidebar.hover(instance, xPos, yPos, false);
                    instance.docked = false;
                } else {
                    sidebar.hover(instance, e.getScreenX(), e.getScreenY(), true);
                }
            }
        };
        onMouseReleased = function(e:MouseEvent):Void {
            if (not docking and not instance.docked) {
                var targetBounds = Sidebar.getInstance().finishHover(instance, e.getScreenX(), e.getScreenY());
                if (targetBounds != null) {
                    docking = true;
                    instance.frame.dock(targetBounds.x, targetBounds.y);
                } else {
                    if (instance.widget.onResize != null) {
                        instance.widget.onResize(instance.widget.stage.width, instance.widget.stage.height);
                    }
                }
                Sidebar.getInstance().dragging = false;
                instance.saveWithoutNotification();
            }
        };
        onMouseEntered = function(e) {requestFocus(true)}
        onMouseExited = function(e) {requestFocus(false)}
    }
}
