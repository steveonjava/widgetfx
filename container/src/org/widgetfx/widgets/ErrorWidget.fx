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
package org.widgetfx.widgets;

import javafx.scene.*;
import javafx.scene.control.*;
import javafx.scene.layout.*;
import javafx.scene.paint.*;
import javafx.scene.shape.*;
import javafx.scene.text.*;
import org.widgetfx.Widget;
import org.widgetfx.ui.WidgetSkin;

/**
 * @author Stephen Chin
 */
public var LINE_HEIGHT = 20;

var X_COLOR = Color.rgb(70, 50, 50);

public class ErrorWidget extends Widget {
    
    public-init var errorLines:String[] = "uninitialized error";
    
    override var width = 300;
    
    override var height = 150;
    
    override var skin = WidgetSkin {
        scene: Group {
            clip: Rectangle {
                smooth: false
                width: bind width
                height: bind height
                arcWidth: 16
                arcHeight: 16
            }
            content: [
                Rectangle {
                    width: bind width
                    height: bind height
                    fill: Color.BLACK
                },
                Line {
                    endX: bind width
                    endY: bind height
                    stroke: X_COLOR
                    strokeWidth: 40
                },
                Line {
                    startX: bind width
                    endY: bind height
                    stroke: X_COLOR
                    strokeWidth: 40
                },
                Group {
                    translateX: bind width / 2
                    translateY: bind height / 2 - LINE_HEIGHT * (errorLines.size().doubleValue() / 2 - 0.5)
                    content: bind for (error in errorLines) {
                        var text:Text;
                        text = Text {
                            translateX: - text.boundsInLocal.width / 2
                            translateY: indexof error * LINE_HEIGHT
                            content: error
                            fill: Color.WHITE
                        }
                    }
                }
            ]
        }
    }
}
