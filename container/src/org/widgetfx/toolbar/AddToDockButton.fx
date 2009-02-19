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

import java.net.URL;
import javafx.scene.*;
import javafx.scene.shape.*;
import javafx.scene.paint.*;
import javafx.scene.transform.*;
import javax.jnlp.*;
import org.widgetfx.*;
import org.widgetfx.config.*;

/**
 * @author Stephen Chin
 * @author Keith Combs
 */
public class AddToDockButton extends ToolbarButton {    
    override var name = "Add to Dock";
    
    var basicService = ServiceManager.lookup("javax.jnlp.BasicService") as BasicService;
    
    override function performAction() {
        basicService.showDocument(new URL("{WidgetFXConfiguration.PUBLIC_CODEBASE}launch.jnlp?arg={toolbar.instance.jnlpUrl}"));
    }
    
    override var visible = bind WidgetManager.getInstance().widgetRunner or not basicService.getCodeBase().toString().equals(WidgetFXConfiguration.PUBLIC_CODEBASE);
    
    override function getShape() {
        [Line { // Border
            stroke: bind Color.BLACK
            strokeWidth: 4
            startX: -3, startY: 0
            endX: 3, endY: 0
        },
        Line { // Border
            stroke: bind Color.BLACK
            strokeWidth: 4
            startX: 0, startY: -3
            endX: 0, endY: 3
        },
        Line {// X Line
            stroke: bind highlightColor
            strokeWidth: 3
            startX: -3, startY: 0
            endX: 3, endY: 0
        },
        Line {// X Line
            stroke: bind highlightColor
            strokeWidth: 3
            startX: 0, startY: -3
            endX: 0, endY: 3
        }];
    }
}
