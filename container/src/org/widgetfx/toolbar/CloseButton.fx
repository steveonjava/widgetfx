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

import javafx.scene.*;
import javafx.scene.shape.*;
import javafx.scene.paint.*;
import javafx.scene.transform.*;

/**
 * @author Stephen Chin
 * @author Keith Combs
 */
public class CloseButton extends ToolbarButton {
    public-init var onClose:function():Void;
    
    override var name = "Close";
    
    override var visible = bind toolbar.instance.widget.configuration == null;
    
    override function performAction() {
        if (toolbar.onClose != null) {
            toolbar.onClose();
        }
    }
    
    override function getShape() {
        [Line { // Border
            stroke: bind Color.BLACK
            strokeWidth: 4
            startX: -3, startY: -3
            endX: 3, endY: 3
        },
        Line { // Border
            stroke: bind Color.BLACK
            strokeWidth: 4
            startX: 3, startY: -3
            endX: -3, endY: 3
        },
        Line {// X Line
            stroke: bind highlightColor
            strokeWidth: 3
            startX: -3, startY: -3
            endX: 3, endY: 3
        },
        Line {// X Line
            stroke: bind highlightColor
            strokeWidth: 3
            startX: 3, startY: -3
            endX: -3, endY: 3
        }];
    }
}
