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

import org.widgetfx.WidgetInstance;
import javafx.animation.*;
import javafx.scene.*;
import javafx.scene.effect.*;
import javafx.scene.input.*;
import javafx.scene.shape.*;
import javafx.scene.paint.*;
import javafx.scene.text.*;
import javafx.scene.transform.*;

/**
 * @author Stephen Chin
 * @author Keith Combs
 */
public var BUTTON_SIZE = 10;
public var BUTTON_SPACING = 3;
public var BUTTON_BORDER = 3;
public var TOOLBAR_HEIGHT = BUTTON_SIZE + BUTTON_BORDER * 2;

public var BACKGROUND = Color.rgb(163, 184, 203);

public class WidgetToolbar extends Group {
    
    public-init var instance:WidgetInstance;
    
    public-init var selectedName:String;
    
    public function setName(name:String):Void {
        selectedName = name;
    }
    
    public-init var onClose:function():Void;
    
    public-init var buttons = bind [
        ConfigButton {
            toolbar: this
        },
        AddToDockButton {
            toolbar: this
        },
        CloseButton {
            toolbar: this
        }
    ];
    
    var visibleButtons = bind buttons[b|b.visible];

    public-read var toolbarWidth = bind visibleButtons.size() * (BUTTON_SIZE + BUTTON_SPACING) - BUTTON_SPACING + BUTTON_BORDER * 2;
    
    var text:Text;

    init {
        content = [
            Group { // Buttons
                clip: Rectangle { // Clip
                    smooth: false
                    width: bind toolbarWidth + 1
                    height: TOOLBAR_HEIGHT + 1
                }
                content: bind [
                    Rectangle { // Border
                        width: bind toolbarWidth
                        height: TOOLBAR_HEIGHT
                        arcWidth: TOOLBAR_HEIGHT
                        arcHeight: TOOLBAR_HEIGHT
                        stroke: Color.BLACK
                    },
                    Rectangle { // Background
                        translateX: 1
                        translateY: 1
                        width: bind toolbarWidth - 2
                        height: TOOLBAR_HEIGHT - 2
                        arcWidth: TOOLBAR_HEIGHT - 2
                        arcHeight: TOOLBAR_HEIGHT - 2
                        stroke: Color.WHITE
                        fill: BACKGROUND
                        opacity: 0.7
                    },
                    for (button in visibleButtons) Group {
                        translateX: BUTTON_SIZE / 2 + BUTTON_BORDER + (BUTTON_SIZE + BUTTON_SPACING) * indexof button
                        translateY: BUTTON_SIZE / 2 + BUTTON_BORDER
                        content: button
                    }
                ]
            },
            Rectangle {
                visible: bind not selectedName.isEmpty()
                translateX: bind - (BUTTON_BORDER * 2 + BUTTON_SPACING + text.boundsInLocal.width)
                width: bind text.boundsInLocal.width + BUTTON_BORDER * 2
                height: TOOLBAR_HEIGHT
                arcWidth: TOOLBAR_HEIGHT
                arcHeight: TOOLBAR_HEIGHT
                fill: Color.WHITESMOKE
                opacity: .7
            },
            text = Text {
                visible: bind not selectedName.isEmpty()
                translateX: bind - (BUTTON_BORDER + BUTTON_SPACING + text.boundsInLocal.width - 1)
                translateY: BUTTON_BORDER
                content: bind selectedName
                textOrigin: TextOrigin.TOP
                fill: Color.BLACK
                smooth: false
                font: Font {size: 10}
            }
        ];
    }
}
