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
package org.widgetfx.toolbar;

import org.widgetfx.*;
import java.net.URL;
import javafx.scene.*;
import javafx.scene.shape.*;
import javafx.scene.paint.*;
import javafx.scene.transform.*;
import javax.jnlp.*;

/**
 * @author Stephen Chin
 * @author Keith Combs
 */
public var PUBLIC_CODEBASE = "http://widgetfx.org/dock/";

public class AddToDockButton extends ToolbarButton {    
    override var name = "Add to Dock";
    
    var basicService = ServiceManager.lookup("javax.jnlp.BasicService") as BasicService;
    
    override function performAction() {
        basicService.showDocument(new URL("{PUBLIC_CODEBASE}launch.jnlp?arg={toolbar.instance.jnlpUrl}"));
    }
    
    override var visible = bind WidgetManager.getInstance().widgetRunner or not basicService.getCodeBase().toString().equals(PUBLIC_CODEBASE);
    
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
