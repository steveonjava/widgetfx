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

import javafx.application.Frame;
import javafx.application.WindowStyle;
import javafx.application.Stage;
import javafx.scene.Group;
import javafx.scene.Cursor;
import javafx.scene.paint.Color;
import javafx.animation.Timeline;
import javafx.animation.KeyFrame;
import javafx.animation.Interpolator;
import javafx.input.MouseEvent;
import javafx.scene.effect.DropShadow;
import javafx.scene.geometry.Rectangle;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseMotionAdapter;
import javax.swing.RootPaneContainer;

/**
 * @author Stephen Chin
 */
public class WidgetFrame extends Frame {
    public static attribute MIN_SIZE = 100;
    public static attribute BORDER = 5;
    public static attribute DS_RADIUS = 5;

    public attribute sidebar:Sidebar;
    
    public attribute widget:Widget;
    
    private attribute widgetTitle = bind widget.name on replace {
        title = widgetTitle;
    }
    
    private attribute widgetWidth = bind widget.stage.width + BORDER * 2 + 1 on replace {
        width = widgetWidth;
    }
    
    private attribute widgetHeight = bind widget.stage.height + BORDER * 2 + 1 on replace {
        height = widgetHeight;
    }

    private attribute resizing:Boolean;
    private attribute dragging:Boolean;
    private attribute docking:Boolean;
    
    private attribute lastScreenPosX;
    private attribute lastScreenPosY;
    private attribute saveLastPos = function(e:MouseEvent):Void {
        lastScreenPosX = e.getStageX().intValue() + x;
        lastScreenPosY = e.getStageY().intValue() + y;
    }
    
    private function mouseDelta(deltaFunction:function(a:Integer, b:Integer):Void):function(c:MouseEvent):Void {
        return function (e:MouseEvent):Void {
            var xDelta = e.getStageX().intValue() + x - lastScreenPosX;
            var yDelta = e.getStageY().intValue() + y - lastScreenPosY;
            saveLastPos(e);
            deltaFunction(xDelta, yDelta);
        }
    }
    
    private attribute startResizing = function(e:MouseEvent):Void {
        resizing = true;
        saveLastPos(e);
    }
    
    private attribute doneResizing = function(e:MouseEvent):Void {
        if (widget.onResize <> null) {
            widget.onResize(widget.stage.width, widget.stage.height);
        }
        resizing = false;
    }    
    
    init {
        windowStyle = WindowStyle.TRANSPARENT;
    }
    
    public function dock(dockX:Integer, dockY:Integer, screenX:Integer, screenY:Integer):Void {
        docking = true;
        Timeline {
            keyFrames: KeyFrame {time: 300ms,
                values: [
                    x => dockX tween Interpolator.EASEIN,
                    y => dockY tween Interpolator.EASEIN
                ],
                action: function() {
                    sidebar.dock(widget, screenX, screenY);
                    close();
                }
            }
        }.start();
    }
    
    private function resize(widthDelta:Integer, heightDelta:Integer, updateX:Boolean, updateY:Boolean) {
        if (widget.stage.width + widthDelta < MIN_SIZE) {
            widthDelta = MIN_SIZE - widget.stage.width;
        }
        if (widget.stage.height < MIN_SIZE) {
            heightDelta = MIN_SIZE - widget.stage.height;
        }
        if (updateX) {
            x -= widthDelta;
        }
        if (updateY) {
            y -= heightDelta;
        }
//        if (widget.aspectRatio <> 0) {
//            var aspectHeight = (newWidth / widget.aspectRatio).intValue();
//            var aspectWidth = (newHeight * widget.aspectRatio).intValue();
//            newWidth = if (aspectWidth > newWidth) then aspectWidth else newWidth;
//            newHeight = if (aspectHeight > newHeight) then aspectHeight else newHeight;
//        }
        widget.stage.width += widthDelta;
        widget.stage.height += heightDelta;
    }
    
    postinit {
        var rolloverOpacity = 0.0;
        var rolloverTimeline = Timeline {
            autoReverse: true, toggle: true
            keyFrames: KeyFrame {time: 1s, values: rolloverOpacity => (if (widget.resizable) then 0.8 else 0.0) tween Interpolator.EASEBOTH}
        }
        var dragRect:Group = Group {
            var transparent = Color.rgb(0, 0, 0, .01);
            content: [
                Rectangle { // border
                    width: bind width - 1, height: bind height - 1
                    stroke: Color.BLACK
                },
                Rectangle { // background
                    translateX: 1, translateY: 1
                    width: bind width - 3, height: bind height - 3
                    fill: Color.rgb(0xF5, 0xF5, 0xF5, 0.6), stroke: Color.WHITESMOKE
                },
                Rectangle { // NW resize corner
                    width: BORDER, height: BORDER
                    stroke: null, fill: transparent
                    cursor: Cursor.NW_RESIZE
                    blocksMouse: true
                    onMousePressed: startResizing
                    onMouseDragged: mouseDelta(function(xDelta:Integer, yDelta:Integer):Void {
                        resize(-xDelta, -yDelta, true, true);
                    })
                    onMouseReleased: doneResizing
                },
                Rectangle { // N resize corner
                    translateX: BORDER, width: bind width - BORDER * 2, height: BORDER
                    stroke: null, fill: transparent
                    cursor: Cursor.N_RESIZE
                    blocksMouse: true
                    onMousePressed: startResizing
                    onMouseDragged: mouseDelta(function(xDelta:Integer, yDelta:Integer):Void {
                        resize(0, -yDelta, false, true);
                    })
                    onMouseReleased: doneResizing
                },
                Rectangle { // NE resize corner
                    translateX: bind width - BORDER, width: BORDER, height: BORDER
                    stroke: null, fill: transparent
                    cursor: Cursor.NE_RESIZE
                    blocksMouse: true
                    onMousePressed: startResizing
                    onMouseDragged: mouseDelta(function(xDelta:Integer, yDelta:Integer):Void {
                        resize(xDelta, -yDelta, false, true);
                    })
                    onMouseReleased: doneResizing
                },
                Rectangle { // E resize corner
                    translateX: bind width - BORDER, translateY: BORDER
                    width: BORDER, height: bind height - BORDER * 2
                    stroke: null, fill: transparent
                    cursor: Cursor.E_RESIZE
                    blocksMouse: true
                    onMousePressed: startResizing
                    onMouseDragged: mouseDelta(function(xDelta:Integer, yDelta:Integer):Void {
                        resize(xDelta, 0, false, false);
                    })
                    onMouseReleased: doneResizing
                },
                Rectangle { // SE resize corner
                    translateX: bind width - BORDER, translateY: bind height - BORDER
                    width: BORDER, height: BORDER
                    stroke: null, fill: transparent
                    cursor: Cursor.SE_RESIZE
                    blocksMouse: true
                    onMousePressed: startResizing
                    onMouseDragged: mouseDelta(function(xDelta:Integer, yDelta:Integer):Void {
                        resize(xDelta, yDelta, false, false);
                    })
                    onMouseReleased: doneResizing
                },
                Rectangle { // S resize corner
                    translateX: BORDER, translateY: bind height - BORDER
                    width: bind width - BORDER * 2, height: BORDER
                    stroke: null, fill: transparent
                    cursor: Cursor.S_RESIZE
                    blocksMouse: true
                    onMousePressed: startResizing
                    onMouseDragged: mouseDelta(function(xDelta:Integer, yDelta:Integer):Void {
                        resize(0, yDelta, false, false);
                    })
                    onMouseReleased: doneResizing
                },
                Rectangle { // SW resize corner
                    translateY: bind height - BORDER, width: BORDER, height: BORDER
                    stroke: null, fill: transparent
                    cursor: Cursor.SW_RESIZE
                    blocksMouse: true
                    onMousePressed: startResizing
                    onMouseDragged: mouseDelta(function(xDelta:Integer, yDelta:Integer):Void {
                        resize(-xDelta, yDelta, true, false);
                    })
                    onMouseReleased: doneResizing
                },
                Rectangle { // W resize corner
                    translateY: BORDER, width: BORDER, height: bind height - BORDER * 2
                    stroke: null, fill: transparent
                    cursor: Cursor.W_RESIZE
                    blocksMouse: true
                    onMousePressed: startResizing
                    onMouseDragged: mouseDelta(function(xDelta:Integer, yDelta:Integer):Void {
                        resize(-xDelta, 0, true, false);
                    })
                    onMouseReleased: doneResizing
                }
            ]
            onMousePressed: saveLastPos;
            onMouseDragged: function(e) {
                if (not docking) {
                    mouseDelta(function(xDelta:Integer, yDelta:Integer):Void {
                        dragging = true;
                        x += xDelta;
                        y += yDelta;
                    })(e);
                    sidebar.hover(widget, e.getScreenX(), e.getScreenY());
                }
            }
            onMouseReleased: function(e) {
                if (not docking) {
                    dragging = false;
                    var screenX = e.getScreenX();
                    var screenY = e.getScreenY();
                    var targetBounds = sidebar.hover(widget, screenX, screenY);
                    if (targetBounds <> null) {
                        dock(targetBounds.x, targetBounds.y, screenX, screenY);
                    }
                }
            }
            opacity: bind rolloverOpacity;
        }
        stage = Stage {
            content: [
                dragRect,
                Group {
                    cache: true
                    translateX: BORDER, translateY: BORDER
                    content: Group {
                        effect: bind if (resizing) then null else DropShadow {offsetX: 2, offsetY: 2, radius: DS_RADIUS}
                        content: Group {
                            content: widget.stage.content
                            clip: Rectangle {width: bind widget.stage.width, height: bind widget.stage.height}
                        }
                    }
                }
            ]
            fill: null
        }
        (window as RootPaneContainer).getContentPane().addMouseListener(MouseAdapter {
            public function mouseEntered(e) {
                rolloverTimeline.start();
            }
            public function mouseExited(e) {
                rolloverTimeline.start();
            }
        });
        visible = true;
    }

}
