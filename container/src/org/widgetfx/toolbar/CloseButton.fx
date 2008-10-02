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

 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
package org.widgetfx.toolbar;

import org.widgetfx.*;
import javafx.scene.*;
import javafx.scene.geometry.*;
import javafx.scene.paint.*;
import javafx.scene.transform.*;

/**
 * @author Stephen Chin
 * @author Keith Combs
 */
public class CloseButton extends ToolbarButton {
    public attribute onClose:function():Void;
    
    protected function performAction() {
        if (onClose != null) {
            onClose();
        }
    }
    
    protected function getShape() {
        [Line { // Border
            stroke: bind Color.BLACK
            strokeWidth: 3
            startX: -3, startY: -3
            endX: 3, endY: 3
        },
        Line { // Border
            stroke: bind Color.BLACK
            strokeWidth: 3
            startX: 3, startY: -3
            endX: -3, endY: 3
        },
        Line {// X Line
            stroke: bind highlightColor
            strokeWidth: 2
            startX: -3, startY: -3
            endX: 3, endY: 3
        },
        Line {// X Line
            stroke: bind highlightColor
            strokeWidth: 2
            startX: 3, startY: -3
            endX: -3, endY: 3
        }];
    }
}
