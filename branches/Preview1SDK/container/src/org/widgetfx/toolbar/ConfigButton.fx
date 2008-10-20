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
import javafx.scene.*;
import javafx.scene.geometry.*;
import javafx.scene.paint.*;
import javafx.scene.transform.*;

/**
 * @author Stephen Chin
 * @author Keith Combs
 */
public class ConfigButton extends ToolbarButton {
    
    override attribute name = "Configuration";
    
    protected function performAction() {
        toolbar.instance.showConfigDialog();
    }
    
    protected function getShape() {
        [Group {// Border
            translateX: 1.4, translateY: -0.4
            transform: [Rotate {angle: 45}, Scale {x: 0.48, y: 0.48}]
            content: [
                Line {startY: 10, endY: 12, stroke: Color.BLACK, strokeWidth: 9},
                ShapeSubtract {
                    fill: Color.BLACK
                    a: Circle {radius: 10}
                    b: Rectangle {x: -5, y: -10, width: 10, height: 12}
                }
            ]
        },
        Group { // Config
            translateX: 1
            transform: [Rotate {angle: 45}, Scale {x: 0.4, y: 0.4}]
            content: [
                Line {startY: 10, endY: 14, stroke: bind highlightColor, strokeWidth: 9},
                ShapeSubtract {
                    fill: bind highlightColor
                    a: Circle {radius: 10}
                    b: Rectangle {x: -5, y: -10, width: 10, height: 12}
                }
            ]
        }];
    }
}
