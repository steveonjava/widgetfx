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
package org.widgetfx.toolbar;

import javafx.scene.*;
import javafx.scene.shape.*;
import javafx.scene.paint.*;
import javafx.scene.transform.*;
import org.widgetfx.*;
import org.widgetfx.ui.*;
import org.widgetfx.widgets.*;

/**
 * @author Stephen Chin
 * @author Keith Combs
 */
public class ConfigButton extends ToolbarButton {
    
    override var name = "Configuration";
    
    override var visible = bind toolbar.instance.widget.configuration != null or toolbar.instance.widget instanceof FlashWidget;
    
    override function performAction() {
        toolbar.instance.showConfigDialog();
    }
    
    override function getShape() {
        [Group {// Border
            translateX: 1.4, translateY: -0.4
            transforms: [Rotate {angle: 45}, Scale {x: 0.48, y: 0.48}]
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
            translateX: 1
            transforms: [Rotate {angle: 45}, Scale {x: 0.4, y: 0.4}]
            content: [
                Line {startY: 10, endY: 14, stroke: bind highlightColor, strokeWidth: 9},
                ShapeSubtract {
                    fill: bind highlightColor
                    a: Circle {radius: 10}
                    b: Rectangle {x: -5, y: -10, width: 10, height: 12}
                }
            ]
        }];
    }
}
