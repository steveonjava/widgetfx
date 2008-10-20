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
package org.widgetfx.ui;

import javafx.application.Stage;
import javafx.scene.*;
import javafx.scene.geometry.*;
import javafx.scene.layout.*;
import javafx.scene.paint.*;
import javafx.scene.text.*;
import org.widgetfx.Widget;

/**
 * @author Stephen Chin
 */
public class ErrorWidget extends Widget {
    private static attribute X_COLOR = Color.rgb(70, 50, 50);
    public static attribute LINE_HEIGHT = 20;
    
    public attribute errorLines:String[] = "uninitialized error";
    
    override attribute autoLaunch = false;
    
    override attribute resizable = true;
    
    override attribute stage = Stage {
        width: 300
        height: 150
        content: [
            Group {
                clip: Rectangle {
                    width: bind stage.width
                    height: bind stage.height
                    arcWidth: 16
                    arcHeight: 16
                }
                content: [
                    Rectangle {
                        width: bind stage.width
                        height: bind stage.height
                        fill: Color.BLACK
                    },
                    Line {
                        endX: bind stage.width
                        endY: bind stage.height
                        stroke: X_COLOR
                        strokeWidth: 40
                    },
                    Line {
                        startX: bind stage.width
                        endY: bind stage.height
                        stroke: X_COLOR
                        strokeWidth: 40
                    },
                    Group {
                        translateX: bind stage.width / 2
                        translateY: bind stage.height / 2 - LINE_HEIGHT * (errorLines.size().doubleValue() / 2 - 0.5)
                        content: bind for (error in errorLines) {
                            Text {
                                translateY: indexof error * LINE_HEIGHT
                                content: error
                                fill: Color.WHITE
                                horizontalAlignment: HorizontalAlignment.CENTER
                            }
                        }
                    }
                ]
            }
        ]
    }
}
