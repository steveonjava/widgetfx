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
package org.widgetfx.widget;
import javafx.application.*;
import javafx.ext.swing.*;
import javafx.async.*;
import javafx.scene.*;
import javafx.scene.geometry.*;
import javafx.animation.*;
import javafx.scene.effect.*;
import javafx.scene.paint.*;
import javafx.scene.transform.*;
import javafx.scene.text.*;
import java.lang.*;

/**
 * @author Stephen Chin
 */
public class Clock extends Application {
    attribute width = 105;
    attribute height = 105;

    attribute date = java.util.Date {};
    attribute bounce : Boolean; // Provides a little analog "jerk"
    attribute seconds = bind date.getSeconds();
    attribute minutes = bind date.getMinutes();
    attribute hours = bind date.getHours();

    attribute timeline = Timeline {
        repeatCount: Timeline.INDEFINITE
        keyFrames: [
            KeyFrame {time: 0.98s, values: bounce => true, action: function():Void {
                    date = java.util.Date {}
                }
            },
            KeyFrame {time: 1s, values: bounce => false}]
    }
    
    public function onStart() {     
        timeline.start();
        content = Canvas {content: [
            Circle { // Clock Rim
                centerX: width / 2, centerY: height / 2, radius: Math.min(width, height) / 2;
                fill: RadialGradient {
                    centerX: 0.6, centerY: -0.6, radius: 2.0
                    stops: [
                        Stop {offset: 0.0, color: Color.WHITE},
                        Stop {offset: 0.35, color: Color.WHITE},
                        Stop {offset: 0.5, color: Color.BLACK},
                        Stop {offset: 0.7, color: Color.WHITE},
                        Stop {offset: 0.85, color: Color.BLACK}
                    ]
                }
            },
            Circle { // Clock Face
                // workaround to prevent the InnerShadow from affecting the size of the clock
                clip: Circle {centerX: width / 2, centerY: height / 2, radius: Math.min(width, height) / 2}
                effect: InnerShadow {radius: 20}
                centerX: width / 2, centerY: height / 2, radius: Math.min(width, height) / 2 - 2.5;
                fill: RadialGradient {
                    centerX: 0.6, centerY: -0.75, radius: 1.5
                    stops: [
                        Stop {offset: 0.0, color: Color.WHITE},
                        Stop {offset: 1.0, color: Color.BLACK}
                    ]
                }
            },
            Group { // Clock Digits
                translateX: width / 2 + 2, translateY: height / 2 + 2
                content: for( i in [1..12] )
                    Text {
                        var radians = Math.toRadians(30 * i - 90)
                        translateX: (width / 2 * .8) * Math.cos(radians)
                        translateY: (height / 2 * .8) * Math.sin(radians)
                        content: "{i}"
                        font: Font {name: "SansSerif", size: 9}
                        textOrigin: TextOrigin.TOP
                        verticalAlignment: VerticalAlignment.CENTER
                        horizontalAlignment: HorizontalAlignment.CENTER
                        fill: Color.WHITE
                    }
            },
            Group { // Clock Hands
                translateX: width / 2, translateY: height / 2
                
                content: [
                    Group { // Hour Hand
                        effect: DropShadow {offsetY: 1, offsetX: 0, radius: 2}
                        content: Line {startX: 0, startY: width / 2 * .2, endX: 0, endY: -width / 2 * .46
                            strokeWidth: 4, stroke: Color.WHITE
                            rotate: bind hours * 30 + minutes / 2
                        }
                    },
                    Group { // Minute Hand
                        effect: DropShadow {offsetY: 2, offsetX: 0, radius: 2}
                        content: Line {startX: 0, startY: width / 2 * .2, endX: 0, endY: -width / 2 * .7
                            strokeWidth: 4, stroke: Color.WHITE
                            rotate: bind minutes * 6 + seconds / 10
                        }
                    },
                    Group { // Second Hand
                        effect: DropShadow {offsetY: 3, offsetX: 0, radius: 2}
                        content: Group {
                            content: [
                                Line {startX: 0, startY: width / 2 * .45, endX: 0, endY: -width / 2 * .75
                                    strokeWidth: 1, stroke: Color.DODGERBLUE
                                },
                                Line {startX: 0, startY: width / 2 * .45, endX: 0, endY: width / 2 * .25
                                    strokeWidth: 3, stroke: Color.DODGERBLUE
                                }
                            ]
                            rotate: bind seconds * 6 + (if (bounce) 3 else 0)
                        }
                    }
                ]
            },
            Circle { // Center Pin
                centerX: width / 2, centerY: height / 2, radius: 3.2
                stroke: Color.DARKSLATEGRAY
                effect: DropShadow {offsetY: 1, radius: 2}
                fill: RadialGradient {
                    centerX: .5
                    centerY: .5
                    stops: [
                        Stop {offset: 0.1, color: Color.DARKSLATEGRAY},
                        Stop {offset: 0.3, color: Color.GRAY},
                        Stop {offset: 0.6, color: Color.LIGHTGRAY}
                    ]
                }
            }
        ]};
    }
}
