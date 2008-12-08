/*
 * WidgetCommandProcessor.fx
 *
 * Created on Dec 4, 2008, 10:01:48 AM
 */

package org.widgetfx;

import org.widgetfx.communication.*;
import org.widgetfx.ui.*;

/**
 * @author schin
 */

public class WidgetCommandProcessor extends CommandProcessor {
    override function hello() {
        return "hi";
    }

    override function addWidget(jnlpUrl:String, x:Number, y:Number):Boolean {
        var added = false;
        for (container in WidgetContainer.containers) {
            added = added or container.addWidget(jnlpUrl, x, y);
        }
        return added;
    }
}
