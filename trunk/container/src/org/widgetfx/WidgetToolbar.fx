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

import javafx.animation.Interpolator;
import javafx.animation.KeyFrame;
import javafx.animation.Timeline;
import javafx.input.MouseEvent;
import javafx.scene.Group;
import javafx.scene.effect.DropShadow;
import javafx.scene.geometry.Circle;
import javafx.scene.geometry.Line;
import javafx.scene.geometry.Rectangle;
import javafx.scene.geometry.ShapeSubtract;
import javafx.scene.paint.Color;
import javafx.scene.transform.Rotate;
import javafx.scene.transform.Scale;

/**
 * @author Stephen Chin
 * @author Keith Combs
 */
public class WidgetToolbar extends Group {
    public static attribute BACKGROUND = Color.rgb(163, 184, 203);
    
    public attribute instance:WidgetInstance;
    
    public attribute onClose:function():Void;

    public attribute toolbarWidth = bind if (instance.widget.configuration == null) 16 else 32;

    init {
        clip = Rectangle { // Clip
            width: toolbarWidth + 1
            height: 17
        };
        content = [
            Rectangle { // Border
                width: toolbarWidth
                height: 16
                arcWidth: 16
                arcHeight: 16
                stroke: Color.BLACK
            },
            Rectangle { // Background
                translateX: 1
                translateY: 1
                width: toolbarWidth - 2
                height: 14
                arcWidth: 14
                arcHeight: 14
                stroke: Color.WHITE
                fill: BACKGROUND
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
                visible: bind instance.widget.configuration != null;
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
                        instance.showConfigDialog();    
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
                translateX: toolbarWidth - 8;
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
                        if (onClose != null) {
                            onClose();
                        }
                    }
                }
            }
        ];
    }
}
