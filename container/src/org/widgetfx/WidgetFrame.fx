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

import org.widgetfx.ui.BaseDialog;
import javafx.application.WindowStyle;
import javafx.application.Stage;
import javafx.scene.Group;
import javafx.scene.Cursor;
import javafx.scene.paint.Color;
import javafx.animation.Timeline;
import javafx.animation.KeyFrame;
import javafx.animation.Interpolator;
import javafx.ext.swing.ComponentView;
import javafx.ext.swing.Slider;
import javafx.input.MouseEvent;
import javafx.lang.DeferredTask;
import javafx.scene.effect.DropShadow;
import javafx.scene.effect.Glow;
import javafx.scene.geometry.Circle;
import javafx.scene.geometry.DelegateShape;
import javafx.scene.geometry.Line;
import javafx.scene.geometry.Rectangle;
import javafx.scene.geometry.ShapeSubtract;
import javafx.scene.paint.RadialGradient;
import javafx.scene.paint.Stop;
import javafx.scene.transform.Rotate;
import javafx.scene.transform.Scale;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseMotionAdapter;
import javax.swing.RootPaneContainer;

/**
 * @author Stephen Chin
 */
public class WidgetFrame extends BaseDialog {
    public static attribute MIN_SIZE = 100;
    public static attribute TOOLBAR_HEIGHT = 18;
    public static attribute BORDER = 5;
    public static attribute DS_RADIUS = 5;
    
    public attribute instance:WidgetInstance;
    
    private attribute widget = bind instance.widget;
    
    private attribute xSync = bind x on replace {
        instance.undockedX = x;
    }
    
    private attribute ySync = bind y on replace {
        instance.undockedY = y;
    }
    
    private attribute widgetWidth = bind widget.stage.width + BORDER * 2 + 1 on replace {
        width = widgetWidth;
    }
    
    private attribute boxHeight = bind widget.stage.height + BORDER * 2 + 1;
    
    private attribute widgetHeight = bind boxHeight + TOOLBAR_HEIGHT on replace {
        height = widgetHeight;
    }

    private attribute resizing:Boolean on replace {
        updateFocus();
    }
    private attribute dragging:Boolean on replace {
        updateFocus();
    }
    private attribute changingOpacity:Boolean on replace {
        updateFocus();
    }
    private attribute docking:Boolean;
    
    private attribute initialX:Integer;
    private attribute initialY:Integer;
    private attribute initialWidth:Integer;
    private attribute initialHeight:Integer;
    private attribute initialScreenX;
    private attribute initialScreenY;
        
    private attribute saveInitialPos = function(e:MouseEvent):Void {
        initialX = x;
        initialY = y;
        initialWidth = widget.stage.width;
        initialHeight = widget.stage.height;
        initialScreenX = e.getStageX().intValue() + x;
        initialScreenY = e.getStageY().intValue() + y;
    }
    
    private function mouseDelta(deltaFunction:function(a:Integer, b:Integer):Void):function(c:MouseEvent):Void {
        return function (e:MouseEvent):Void {
            var xDelta = e.getStageX().intValue() + x - initialScreenX;
            var yDelta = e.getStageY().intValue() + y - initialScreenY;
            deltaFunction(xDelta, yDelta);
        }
    }
    
    private attribute startResizing = function(e:MouseEvent):Void {
        resizing = true;
        saveInitialPos(e);
    }
    
    private attribute doneResizing = function(e:MouseEvent):Void {
        if (widget.onResize != null) {
            widget.onResize(widget.stage.width, widget.stage.height);
        }
        instance.saveWithoutNotification();
        resizing = false;
    }
    
    init {
        windowStyle = WindowStyle.TRANSPARENT;
        title = instance.title;
    }
    
    public function dock(dockX:Integer, dockY:Integer):Void {
        docking = true;
        Timeline {
            keyFrames: KeyFrame {time: 300ms,
                values: [
                    x => dockX - BORDER tween Interpolator.EASEIN,
                    y => dockY - BORDER - TOOLBAR_HEIGHT tween Interpolator.EASEIN
                ],
                action: function() {
                    Sidebar.getInstance().dock(instance);
                    if (instance.widget.onResize != null) {
                        instance.widget.onResize(instance.widget.stage.width, instance.widget.stage.height);
                    }
                    instance.frame = null;
                    close();
                }
            }
        }.start();
    }
    
    private function resize(widthDelta:Integer, heightDelta:Integer, updateX:Boolean, updateY:Boolean, widthOnly:Boolean, heightOnly:Boolean) {
        if (initialWidth + widthDelta < MIN_SIZE) {
            widthDelta = MIN_SIZE - initialWidth;
        }
        if (initialHeight + heightDelta < MIN_SIZE) {
            heightDelta = MIN_SIZE - initialHeight;
        }
        var newWidth = initialWidth + widthDelta;
        var newHeight = initialHeight + heightDelta;
        if (widget.aspectRatio != 0) {
            var aspectHeight = (newWidth / widget.aspectRatio).intValue();
            var aspectWidth = (newHeight * widget.aspectRatio).intValue();
            newWidth = if (not widthOnly and (heightOnly or aspectWidth < newWidth)) aspectWidth else newWidth;
            newHeight = if (not heightOnly and (widthOnly or aspectHeight < newHeight)) aspectHeight else newHeight;
        }
        if (updateX) {
            x = initialX + initialWidth - newWidth;
        }
        if (updateY) {
            y = initialY + initialHeight - newHeight;
        }
        widget.stage.width = newWidth;
        widget.stage.height = newHeight;
    }
    
    private attribute rolloverOpacity = 0.0;
    private attribute rolloverTimeline = Timeline {
        autoReverse: true, toggle: true
        keyFrames: KeyFrame {time: 1s, values: rolloverOpacity => 1.0 tween Interpolator.EASEBOTH}
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
    
    private function requestFocus(focus:Boolean):Void {
        needsFocus = focus;
        updateFocus();
    }
    
    private function updateFocus():Void {
        DeferredTask {
            action: function() {
                hasFocus = needsFocus or dragging or resizing or changingOpacity;
            }
        }
    }
    
    postinit {
        var dragRect:Group = Group {
            var backgroundColor = Color.rgb(0xF5, 0xF5, 0xF5, 0.6);
            translateY: TOOLBAR_HEIGHT,
            content: [
                Rectangle { // background
                    translateX: BORDER, translateY: BORDER
                    width: bind width - BORDER * 2, height: bind boxHeight - BORDER * 2
                    fill: backgroundColor, stroke: null
                    opacity: bind (instance.opacity as Number) / 100
                },
                Rectangle { // NW resize corner
                    width: BORDER, height: BORDER
                    stroke: null, fill: backgroundColor
                    cursor: Cursor.NW_RESIZE
                    blocksMouse: true
                    onMousePressed: startResizing
                    onMouseDragged: mouseDelta(function(xDelta:Integer, yDelta:Integer):Void {
                        resize(-xDelta, -yDelta, true, true, false, false);
                    })
                    onMouseReleased: doneResizing
                },
                Rectangle { // N resize corner
                    translateX: BORDER, width: bind width - BORDER * 2, height: BORDER
                    stroke: null, fill: backgroundColor
                    cursor: Cursor.N_RESIZE
                    blocksMouse: true
                    onMousePressed: startResizing
                    onMouseDragged: mouseDelta(function(xDelta:Integer, yDelta:Integer):Void {
                        resize(0, -yDelta, false, true, false, true);
                    })
                    onMouseReleased: doneResizing
                },
                Rectangle { // NE resize corner
                    translateX: bind width - BORDER, width: BORDER, height: BORDER
                    stroke: null, fill: backgroundColor
                    cursor: Cursor.NE_RESIZE
                    blocksMouse: true
                    onMousePressed: startResizing
                    onMouseDragged: mouseDelta(function(xDelta:Integer, yDelta:Integer):Void {
                        resize(xDelta, -yDelta, false, true, false, false);
                    })
                    onMouseReleased: doneResizing
                },
                Rectangle { // E resize corner
                    translateX: bind width - BORDER, translateY: BORDER
                    width: BORDER, height: bind boxHeight - BORDER * 2
                    stroke: null, fill: backgroundColor
                    cursor: Cursor.E_RESIZE
                    blocksMouse: true
                    onMousePressed: startResizing
                    onMouseDragged: mouseDelta(function(xDelta:Integer, yDelta:Integer):Void {
                        resize(xDelta, 0, false, false, true, false);
                    })
                    onMouseReleased: doneResizing
                },
                Rectangle { // SE resize corner
                    translateX: bind width - BORDER, translateY: bind boxHeight - BORDER
                    width: BORDER, height: BORDER
                    stroke: null, fill: backgroundColor
                    cursor: Cursor.SE_RESIZE
                    blocksMouse: true
                    onMousePressed: startResizing
                    onMouseDragged: mouseDelta(function(xDelta:Integer, yDelta:Integer):Void {
                        resize(xDelta, yDelta, false, false, false, false);
                    })
                    onMouseReleased: doneResizing
                },
                Rectangle { // S resize corner
                    translateX: BORDER, translateY: bind boxHeight - BORDER
                    width: bind width - BORDER * 2, height: BORDER
                    stroke: null, fill: backgroundColor
                    cursor: Cursor.S_RESIZE
                    blocksMouse: true
                    onMousePressed: startResizing
                    onMouseDragged: mouseDelta(function(xDelta:Integer, yDelta:Integer):Void {
                        resize(0, yDelta, false, false, false, true);
                    })
                    onMouseReleased: doneResizing
                },
                Rectangle { // SW resize corner
                    translateY: bind boxHeight - BORDER, width: BORDER, height: BORDER
                    stroke: null, fill: backgroundColor
                    cursor: Cursor.SW_RESIZE
                    blocksMouse: true
                    onMousePressed: startResizing
                    onMouseDragged: mouseDelta(function(xDelta:Integer, yDelta:Integer):Void {
                        resize(-xDelta, yDelta, true, false, false, false);
                    })
                    onMouseReleased: doneResizing
                },
                Rectangle { // W resize corner
                    translateY: BORDER, width: BORDER, height: bind boxHeight - BORDER * 2
                    stroke: null, fill: backgroundColor
                    cursor: Cursor.W_RESIZE
                    blocksMouse: true
                    onMousePressed: startResizing
                    onMouseDragged: mouseDelta(function(xDelta:Integer, yDelta:Integer):Void {
                        resize(-xDelta, 0, true, false, true, false);
                    })
                    onMouseReleased: doneResizing
                },
                Rectangle { // outer border
                    width: bind width - 1, height: bind boxHeight - 1
                    stroke: Color.BLACK
                },
                Rectangle { // inner border
                    translateX: 1, translateY: 1
                    width: bind width - 3, height: bind boxHeight - 3
                    stroke: Color.WHITESMOKE
                }
            ]
            onMousePressed: saveInitialPos;
            onMouseDragged: function(e) {
                if (not docking) {
                    mouseDelta(function(xDelta:Integer, yDelta:Integer):Void {
                        dragging = true;
                        x = initialX + xDelta;
                        y = initialY + yDelta;
                    })(e);
                    Sidebar.getInstance().hover(instance, e.getScreenX(), e.getScreenY(), true);
                }
            }
            onMouseReleased: function(e) {
                if (not docking) {
                    dragging = false;
                    var targetBounds = Sidebar.getInstance().finishHover(instance, e.getScreenX(), e.getScreenY());
                    if (targetBounds != null) {
                        dock(targetBounds.x, targetBounds.y);
                    }
                    instance.saveWithoutNotification();
                }
            }
            opacity: bind if (widget.resizable) rolloverOpacity * 0.8 else 0.0;
        }
        var slider = Slider {
            minimum: 20
            maximum: 100
            value: bind instance.opacity with inverse
            preferredSize: bind [width * 2 / 5, 16]
        }
        var toolbarBackground = Color.rgb(163, 184, 203);
        stage = Stage {
            content: [
                dragRect,
                Group {
                    cache: true
                    translateX: BORDER, translateY: BORDER + TOOLBAR_HEIGHT
                    content: Group {
                        effect: bind if (resizing) null else DropShadow {offsetX: 2, offsetY: 2, radius: DS_RADIUS}
                        content: Group {
                            content: widget.stage.content
                            clip: Rectangle {width: bind widget.stage.width, height: bind widget.stage.height}
                        }
                    }
                    onMouseClicked: function(e:MouseEvent):Void {
                        if (e.getButton() == 3) {
                            WidgetManager.getInstance().showConfigDialog(widget);
                        }
                    }
                    opacity: bind (instance.opacity as Number) / 100
                },
                Group { // Transparency Slider
                    content: [
                        Rectangle { // Borer
                            width: bind width * 2 / 5 + 2
                            height: 16
                            arcWidth: 16
                            arcHeight: 16
                            stroke: Color.BLACK
                        },
                        Rectangle { // Background
                            translateX: 1
                            translateY: 1
                            width: bind width * 2 / 5
                            height: 14
                            arcWidth: 14
                            arcHeight: 14
                            stroke: Color.WHITE
                            fill: toolbarBackground
                            opacity: 0.7
                        },
                        ComponentView { // Slider
                            translateX: 1
                            component: slider
                        }
                    ]
                    opacity: bind rolloverOpacity
                },
                Group { // Toolbar
                    var TOOLBAR_WIDTH = 32;
                    translateX: bind width - TOOLBAR_WIDTH - 1
                    content: [
                        Rectangle { // Border
                            width: TOOLBAR_WIDTH
                            height: 16
                            arcWidth: 16
                            arcHeight: 16
                            stroke: Color.BLACK
                        },
                        Rectangle { // Background
                            translateX: 1
                            translateY: 1
                            width: TOOLBAR_WIDTH - 2
                            height: 14
                            arcWidth: 14
                            arcHeight: 14
                            stroke: Color.WHITE
                            fill: toolbarBackground
                            opacity: 0.7
                        },
                        Group { // Config Button
                            var pressedColor = Color.rgb(54, 101, 143);
                            var dsColor = Color.BLACK;
                            var dsTimeline = Timeline {
                                toggle: true, autoReverse: true
                                keyFrames: KeyFrame {
                                    time: 300ms
                                    values: [
                                        dsColor => Color.WHITE tween Interpolator.EASEBOTH
                                    ]
                                }
                            }
                            var hover = false on replace {
                                dsTimeline.start();
                            }
                            var pressed = false;
                            var xColor = bind if (hover and pressed) pressedColor else Color.WHITE;
                            effect: DropShadow {color: bind dsColor}
                            content: Group {
                                translateX: 11, translateY: 8
                                content: [
                                    Rectangle { // Bounding Rect (for rollover)
                                        x: -5, y: -5
                                        width: 10, height: 10
                                        fill: Color.rgb(0, 0, 0, 0.0)
                                    },
                                    Group {// Border
                                        translateX: 0.4, translateY: -0.4
                                        transform: [Rotate {angle: 45}, Scale {x: 0.48, y: 0.48}]
                                        content: [
                                            Line {startY: 10, endY: 12, stroke: Color.BLACK, strokeWidth: 9},
                                            ShapeSubtract {
                                                fill: Color.BLACK
                                                a: Circle {radius: 10}
                                                b: Rectangle {x: -5, y: -10, width: 10, height: 12}
                                            }
                                        ]
                                    },
                                    Group { // Config
                                        transform: [Rotate {angle: 45}, Scale {x: 0.4, y: 0.4}]
                                        content: [
                                            Line {startY: 10, endY: 14, stroke: bind xColor, strokeWidth: 9},
                                            ShapeSubtract {
                                                fill: bind xColor
                                                a: Circle {radius: 10}
                                                b: Rectangle {x: -5, y: -10, width: 10, height: 12}
                                            }
                                        ]
                                    }
                                ]
                            }
                            onMouseEntered: function(e) {
                                hover = true;
                            }
                            onMouseExited: function(e) {
                                hover = false;
                            }
                            onMousePressed: function(e) {
                                pressed = true;
                            }
                            onMouseReleased: function(e:MouseEvent) {
                                pressed = false;
                                if (hover) {
                                    WidgetManager.getInstance().showConfigDialog(widget);    
                                }
                            }
                        },
                        Group { // Close Button
                            var pressedColor = Color.rgb(54, 101, 143);
                            var dsColor = Color.BLACK;
                            var dsTimeline = Timeline {
                                toggle: true, autoReverse: true
                                keyFrames: KeyFrame {
                                    time: 300ms
                                    values: [
                                        dsColor => Color.WHITE tween Interpolator.EASEBOTH
                                    ]
                                }
                            }
                            var hover = false on replace {
                                dsTimeline.start();
                            }
                            var pressed = false;
                            var xColor = bind if (hover and pressed) pressedColor else Color.WHITE;
                            translateX: TOOLBAR_WIDTH - 8;
                            translateY: 8;
                            effect: DropShadow {color: bind dsColor}
                            content: [
                                Rectangle { // Bounding Rect (for rollover)
                                    x: -5, y: -5
                                    width: 10, height: 10
                                    fill: Color.rgb(0, 0, 0, 0.0)
                                },
                                Line { // Border
                                    stroke: bind Color.BLACK
                                    strokeWidth: 3
                                    startX: -3, startY: -3
                                    endX: 3, endY: 3
                                },
                                Line { // Border
                                    stroke: bind Color.BLACK
                                    strokeWidth: 3
                                    startX: 3, startY: -3
                                    endX: -3, endY: 3
                                },
                                Line {// X Line
                                    stroke: bind xColor
                                    strokeWidth: 2
                                    startX: -3, startY: -3
                                    endX: 3, endY: 3
                                },
                                Line {// X Line
                                    stroke: bind xColor
                                    strokeWidth: 2
                                    startX: 3, startY: -3
                                    endX: -3, endY: 3
                                }
                            ]
                            onMouseEntered: function(e) {
                                hover = true;
                            }
                            onMouseExited: function(e) {
                                hover = false;
                            }
                            onMousePressed: function(e) {
                                pressed = true;
                            }
                            onMouseReleased: function(e:MouseEvent) {
                                pressed = false;
                                if (hover) {
                                    WidgetManager.getInstance().removeWidget(instance);
                                    close();
                                }
                            }
                        }
                    ]
                    opacity: bind rolloverOpacity
                }
            ]
            fill: null
        }
        (window as RootPaneContainer).getContentPane().addMouseListener(MouseAdapter {
            public function mouseEntered(e) {
                requestFocus(true);
            }
            public function mouseExited(e) {
                requestFocus(false);
            }
        });
        slider.getJSlider().addMouseListener(MouseAdapter {
            public function mouseEntered(e) {
                requestFocus(true);
            }
            public function mouseExited(e) {
                requestFocus(false);
            }
            public function mousePressed(e) {
                changingOpacity = true;
            }
            public function mouseReleased(e) {
                changingOpacity = false;
            }
        });
        visible = true;
    }

}
