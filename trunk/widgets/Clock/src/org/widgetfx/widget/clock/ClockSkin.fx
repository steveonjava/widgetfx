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
package org.widgetfx.widget.clock;

import org.jfxtras.scene.*;
import javafx.ext.swing.*;
import javafx.animation.*;
import javafx.async.*;
import javafx.scene.*;
import javafx.scene.control.*;
import javafx.scene.effect.*;
import javafx.scene.paint.*;
import javafx.scene.shape.*;
import javafx.scene.transform.*;
import javafx.scene.text.*;
import java.lang.*;

/**
 * @author Stephen Chin
 */
public class ClockSkin extends Skin {
    public var rimStartColor = Color.WHITE;
    public var rimEndColor = Color.BLACK;
    public var faceStartColor = Color.WHITE;
    public var faceEndColor = Color.BLACK;
    public var shadowColor = Color.BLACK;
    public var digitColor = Color.WHITE;
    public var hourHandColor = Color.WHITE;
    public var minuteHandColor = Color.WHITE;
    public var secondHandColor = Color.DODGERBLUE;

    var date = java.util.Date {};
    var bounce : Boolean; // Provides a little analog "jerk"
    var seconds = bind date.getSeconds();
    var minutes = bind date.getMinutes();
    var hours = bind date.getHours();

    var timeline = Timeline {
        repeatCount: Timeline.INDEFINITE
        keyFrames: [
            KeyFrame {time: 0.96s, values: bounce => true, action: function():Void {
                    date = java.util.Date {}
                }
            },
            KeyFrame {time: 1s, values: bounce => false}]
    }

    init {
        timeline.play();
        scene = Group {
            content: [
                CacheSafeGroup { // Static Content
                    cache: true
                    content: [
                        Circle { // Clock Rim
                            centerX: bind control.width / 2, centerY: bind control.height / 2, radius: bind Math.min(control.width, control.height) / 2
                            fill: bind RadialGradient {
                                centerX: 0.6, centerY: -0.6, radius: 2.0
                                stops: [
                                    Stop {offset: 0.0, color: rimStartColor},
                                    Stop {offset: 0.35, color: rimStartColor},
                                    Stop {offset: 0.5, color: rimEndColor},
                                    Stop {offset: 0.7, color: rimStartColor},
                                    Stop {offset: 0.85, color: rimEndColor}
                                ]
                            }
                        },
                        Circle { // Clock Shadow
                            centerX: bind control.width / 2, centerY: bind control.height / 2, radius: bind Math.min(control.width, control.height) / 2 - 2.5
                            fill: bind shadowColor
                        },
                        Circle { // Clock Face
                            // workaround to prevent the InnerShadow from affecting the size of the clock
                            centerX: bind control.width / 2, centerY: bind control.height / 2 - 0.5, radius: bind Math.min(control.width, control.height) / 2 - 5.5
                            fill: bind RadialGradient {
                                centerX: 0.6, centerY: -0.75, radius: 1.5
                                stops: [
                                    Stop {offset: 0.0, color: faceStartColor},
                                    Stop {offset: 1.0, color: faceEndColor}
                                ]
                            }
                        },
                        Group { // Clock Digits
                            translateX: bind control.width / 2 - 3, translateY: bind control.height / 2 + 4
                            content: for( i in [1..12] )
                                Text {
                                    var radians = Math.toRadians(30 * i - 90)
                                    translateX: bind (control.width / 2 * .8) * Math.cos(radians)
                                    translateY: bind (control.height / 2 * .8) * Math.sin(radians)
                                    content: "{i}"
                                    font: Font {name: "SansSerif", size: 9}
                                    textOrigin: TextOrigin.BASELINE
                                    textAlignment: TextAlignment.CENTER
                                    fill: bind digitColor
                                }
                        },
                    ]
                },
                Group { // Clock Hands
                    translateX: bind control.width / 2, translateY: bind control.height / 2

                    content: [
                        CacheSafeGroup { // Hour Hand
                            cache: true
                            effect: DropShadow {offsetY: 1, offsetX: 0, radius: 2}
                            content: Line {startX: 0, startY: bind control.width / 2 * .2, endX: 0, endY: bind -control.width / 2 * .46
                                strokeWidth: 4, stroke: bind hourHandColor
                                transforms: bind Transform.rotate(hours * 30 + minutes / 2, 0, 0)
                            }
                        },
                        CacheSafeGroup { // Minute Hand
                            cache: true
                            effect: DropShadow {offsetY: 2, offsetX: 0, radius: 2}
                            content: Line {startX: 0, startY: bind control.width / 2 * .2, endX: 0, endY: bind -control.width / 2 * .7
                                strokeWidth: 4, stroke: bind minuteHandColor
                                transforms: bind Transform.rotate(minutes * 6 + seconds / 10, 0, 0)
                            }
                        },
                        Group { // Second Hand
                            effect: DropShadow {offsetY: 3, offsetX: 0, radius: 2}
                            content: Group {
                                content: [
                                    Line {startX: 0, startY: bind control.width / 2 * .45, endX: 0, endY: bind -control.width / 2 * .75
                                        strokeWidth: 1, stroke: bind secondHandColor
                                    },
                                    Line {startX: 0, startY: bind control.width / 2 * .45, endX: 0, endY: bind control.width / 2 * .25
                                        strokeWidth: 3, stroke: bind secondHandColor
                                    }
                                ]
                                transforms: bind Transform.rotate(seconds * 6 + (if (bounce) 2 else 0), 0, 0)
                            }
                        }
                    ]
                },
                CacheSafeGroup { // Center Pin
                    cache: true
                    content: Circle {
                        centerX: bind control.width / 2, centerY: bind control.height / 2, radius: 3.2
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
                }
            ]
        }
    }
}
