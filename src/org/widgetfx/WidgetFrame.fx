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
import javafx.scene.geometry.Rectangle;
import java.awt.event.MouseAdapter;
import javax.swing.RootPaneContainer;

/**
 * @author Stephen Chin
 */
public class WidgetFrame extends Frame {
    public static attribute BORDER = 5;

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
    
    public attribute wrapper:Group;

    init {
        windowStyle = WindowStyle.TRANSPARENT;
    }
    
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
                    onMousePressed: saveLastPos
                    onMouseDragged: mouseDelta(function(xDelta:Integer, yDelta:Integer):Void {
                        widget.stage.width -= xDelta;
                        x += xDelta;
                        widget.stage.height -= yDelta;
                        y += yDelta;
                    })
                },
                Rectangle { // N resize corner
                    translateX: BORDER, width: bind width - BORDER * 2, height: BORDER
                    stroke: null, fill: transparent
                    cursor: Cursor.N_RESIZE
                    blocksMouse: true
                    onMousePressed: saveLastPos
                    onMouseDragged: mouseDelta(function(xDelta:Integer, yDelta:Integer):Void {
                        widget.stage.height -= yDelta;
                        y += yDelta;
                    })
                },
                Rectangle { // NE resize corner
                    translateX: bind width - BORDER, width: BORDER, height: BORDER
                    stroke: null, fill: transparent
                    cursor: Cursor.NE_RESIZE
                    blocksMouse: true
                    onMousePressed: saveLastPos
                    onMouseDragged: mouseDelta(function(xDelta:Integer, yDelta:Integer):Void {
                        widget.stage.width += xDelta;
                        y += yDelta;
                        widget.stage.height -= yDelta;
                    })
                },
                Rectangle { // E resize corner
                    translateX: bind width - BORDER, translateY: BORDER
                    width: BORDER, height: bind height - BORDER * 2
                    stroke: null, fill: transparent
                    cursor: Cursor.E_RESIZE
                    blocksMouse: true
                    onMousePressed: saveLastPos
                    onMouseDragged: mouseDelta(function(xDelta:Integer, yDelta:Integer):Void {
                        widget.stage.width += xDelta;
                    })
                },
                Rectangle { // SE resize corner
                    translateX: bind width - BORDER, translateY: bind height - BORDER
                    width: BORDER, height: BORDER
                    stroke: null, fill: transparent
                    cursor: Cursor.SE_RESIZE
                    blocksMouse: true
                    onMousePressed: saveLastPos
                    onMouseDragged: mouseDelta(function(xDelta:Integer, yDelta:Integer):Void {
                        widget.stage.width += xDelta;
                        widget.stage.height += yDelta;
                    })
                },
                Rectangle { // S resize corner
                    translateX: BORDER, translateY: bind height - BORDER
                    width: bind width - BORDER * 2, height: BORDER
                    stroke: null, fill: transparent
                    cursor: Cursor.S_RESIZE
                    blocksMouse: true
                    onMousePressed: saveLastPos
                    onMouseDragged: mouseDelta(function(xDelta:Integer, yDelta:Integer):Void {
                        widget.stage.height += yDelta;
                    })
                },
                Rectangle { // SW resize corner
                    translateY: bind height - BORDER, width: BORDER, height: BORDER
                    stroke: null, fill: transparent
                    cursor: Cursor.SW_RESIZE
                    blocksMouse: true
                    onMousePressed: saveLastPos
                    onMouseDragged: mouseDelta(function(xDelta:Integer, yDelta:Integer):Void {
                        widget.stage.width -= xDelta;
                        x += xDelta;
                        widget.stage.height += yDelta;
                    })
                },
                Rectangle { // W resize corner
                    translateY: BORDER, width: BORDER, height: bind height - BORDER * 2
                    stroke: null, fill: transparent
                    cursor: Cursor.W_RESIZE
                    blocksMouse: true
                    onMousePressed: saveLastPos
                    onMouseDragged: mouseDelta(function(xDelta:Integer, yDelta:Integer):Void {
                        widget.stage.width -= xDelta;
                        x += xDelta;
                    })
                }
            ]
            opacity: bind rolloverOpacity;
        }
        stage = Stage {
            content: [
                dragRect,
                Group {
                    translateX: BORDER, translateY: BORDER
                    content: wrapper
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
