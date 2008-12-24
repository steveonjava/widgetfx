/*
 * WidgetCommandProcessor.fx
 *
 * Created on Dec 4, 2008, 10:01:48 AM
 */

package org.widgetfx;

import org.jfxtras.util.*;
import org.widgetfx.communication.*;
import org.widgetfx.ui.*;
import javafx.geometry.*;

/**
 * @author schin
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

    override function finishHover(jnlpUrl:String, x:Number, y:Number) {
        var dropBounds:Rectangle2D = null;
        for (dragListener in WidgetDragListener.dragListeners) {
            var result = dragListener.finishHover(jnlpUrl, x, y);
            if (result != null) {
                dropBounds = result;
            }
        }
        return GeometryUtil.rectangleToJava(dropBounds);
    }
}
