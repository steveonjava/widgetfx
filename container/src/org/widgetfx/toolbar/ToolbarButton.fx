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

import org.widgetfx.*;
import javafx.animation.*;
import javafx.scene.*;
import javafx.scene.effect.*;
import javafx.scene.input.*;
import javafx.scene.shape.*;
import javafx.scene.paint.*;

/**
 * @author Stephen Chin
 * @author Keith Combs
 */
var pressedColor = Color.rgb(54, 101, 143);

public abstract class ToolbarButton extends Group {
    public-init var toolbar:WidgetToolbar;

    public-init protected var name:String;
    
    protected abstract function performAction():Void;

    protected abstract function getShape():Node[];

    protected var highlightColor = bind if (hover and pressed) pressedColor else Color.WHITE;
    
    var dsColor = Color.BLACK;
    var dsTimeline = Timeline {
        keyFrames: KeyFrame {
            time: 300ms
            values: [
                dsColor => Color.WHITE tween Interpolator.EASEBOTH
            ]
        }
    }
    
    override var hover on replace {
        dsTimeline.rate = if (hover) 1 else -1;
        dsTimeline.play();
        toolbar.setName(if (hover) then name else "");
    }
    
    override var onMouseReleased = function(e:MouseEvent) {
        if (hover) {
            performAction();
        }
    }
    
    init {
        effect = DropShadow {color: bind dsColor};
        content = [
            Rectangle { // Bounding Rect (for rollover)
                x: -WidgetToolbar.BUTTON_SIZE / 2, y: -WidgetToolbar.BUTTON_SIZE / 2
                width: WidgetToolbar.BUTTON_SIZE, height: WidgetToolbar.BUTTON_SIZE
                fill: Color.rgb(0, 0, 0, 0.0)
            },
            getShape()
        ];
    }
}
