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

import org.widgetfx.WidgetInstance;
import javafx.animation.Interpolator;
import javafx.animation.KeyFrame;
import javafx.animation.Timeline;
import javafx.input.MouseEvent;
import javafx.scene.*;
import javafx.scene.effect.DropShadow;
import javafx.scene.geometry.Circle;
import javafx.scene.geometry.Line;
import javafx.scene.geometry.Rectangle;
import javafx.scene.geometry.ShapeSubtract;
import javafx.scene.paint.Color;
import javafx.scene.text.*;
import javafx.scene.transform.Rotate;
import javafx.scene.transform.Scale;

/**
 * @author Stephen Chin
 * @author Keith Combs
 */
public class WidgetToolbar extends Group {
    public static attribute BUTTON_SIZE = 10;
    public static attribute BUTTON_SPACING = 3;
    public static attribute BUTTON_BORDER = 3;
    public static attribute TOOLBAR_HEIGHT = BUTTON_SIZE + BUTTON_BORDER * 2;
    
    public static attribute BACKGROUND = Color.rgb(163, 184, 203);
    
    public attribute instance:WidgetInstance;
    
    private attribute selectedName:String = null;
    
    public function setName(name:String):Void {
        selectedName = name;
    }
    
    public attribute onClose:function():Void;
    
    public attribute buttons = bind [
        ConfigButton {
            toolbar: this
        },
        AddToDockButton {
            toolbar: this
        },
        CloseButton {
            toolbar: this
        }
    ];
    
    public attribute visibleButtons = bind buttons[b|b.visible];

    public attribute toolbarWidth = bind visibleButtons.size() * (BUTTON_SIZE + BUTTON_SPACING) - BUTTON_SPACING + BUTTON_BORDER * 2;
    
    private attribute text = Text {
        visible: bind selectedName != null
        translateX: bind -toolbarWidth - BUTTON_BORDER * 2
        translateY: BUTTON_BORDER
        content: bind selectedName
        textOrigin: TextOrigin.TOP
        horizontalAlignment: HorizontalAlignment.RIGHT
        fill: Color.BLACK
        font: Font {size: 10}
    }

    override attribute content = bind [
        Group { // Buttons
            translateX: bind -toolbarWidth - 1
            clip: Rectangle { // Clip
                width: bind toolbarWidth + 1
                height: TOOLBAR_HEIGHT + 1
            }
            content: bind [
                Rectangle { // Border
                    width: bind toolbarWidth
                    height: TOOLBAR_HEIGHT
                    arcWidth: TOOLBAR_HEIGHT
                    arcHeight: TOOLBAR_HEIGHT
                    stroke: Color.BLACK
                },
                Rectangle { // Background
                    translateX: 1
                    translateY: 1
                    width: bind toolbarWidth - 2
                    height: TOOLBAR_HEIGHT - 2
                    arcWidth: TOOLBAR_HEIGHT - 2
                    arcHeight: TOOLBAR_HEIGHT - 2
                    stroke: Color.WHITE
                    fill: BACKGROUND
                    opacity: 0.7
                },
                for (button in visibleButtons) Group {
                    translateX: BUTTON_SIZE / 2 + BUTTON_BORDER + (BUTTON_SIZE + BUTTON_SPACING) * indexof button
                    translateY: BUTTON_SIZE / 2 + BUTTON_BORDER
                    content: button
                }
            ]
        },
        Rectangle {
            visible: bind selectedName != null
            translateX: bind -toolbarWidth - BUTTON_BORDER
            width: bind text.getWidth() + BUTTON_BORDER * 2
            height: TOOLBAR_HEIGHT
            arcWidth: TOOLBAR_HEIGHT
            arcHeight: TOOLBAR_HEIGHT
            horizontalAlignment: HorizontalAlignment.RIGHT
            fill: Color.WHITESMOKE
            opacity: .7
        },
        text
    ];
}
