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

 * This particular file is subject to the "Classpath" exception as provided
 * in the LICENSE file that accompanied this code.

 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
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
