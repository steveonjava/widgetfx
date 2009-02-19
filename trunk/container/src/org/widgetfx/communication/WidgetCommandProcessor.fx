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
package org.widgetfx.communication;

import org.jfxtras.util.*;
import org.widgetfx.communication.*;
import org.widgetfx.ui.*;
import javafx.geometry.*;
import java.util.Properties;

/**
 * @author Stephen Chin
 */
public class WidgetCommandProcessor extends CommandProcessor {
    override function hover(dockedHeight:Number, x:Number, y:Number) {
        var hoverBounds:Rectangle2D = null;
        for (dragListener in WidgetDragListener.dragListeners) {
            var result = dragListener.hover(dockedHeight, x, y);
            if (result != null) {
                hoverBounds = result;
            }
        }
        return GeometryUtil.rectangleToJava(hoverBounds);
    }

    override function finishHover(jnlpUrl:String, x:Number, y:Number, properties:Properties) {
        var dropBounds:Rectangle2D = null;
        for (dragListener in WidgetDragListener.dragListeners) {
            var result = dragListener.finishHover(jnlpUrl, x, y, properties);
            if (result != null) {
                dropBounds = result;
            }
        }
        return GeometryUtil.rectangleToJava(dropBounds);
    }
}
