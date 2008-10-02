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

import javafx.animation.*;
import javafx.input.*;
import javafx.scene.*;
import javafx.scene.effect.*;
import javafx.scene.geometry.*;
import javafx.scene.paint.*;

/**
 * @author Stephen Chin
 * @author Keith Combs
 */
public abstract class ToolbarButton extends Group {
    private static attribute pressedColor = Color.rgb(54, 101, 143);

    protected abstract function performAction():Void;

    protected abstract function getShape():Node[];

    protected attribute highlightColor = bind if (hover and pressed) pressedColor else Color.WHITE;
    
    private attribute dsColor = Color.BLACK;
    private attribute dsTimeline = Timeline {
        toggle: true, autoReverse: true
        keyFrames: KeyFrame {
            time: 300ms
            values: [
                dsColor => Color.WHITE tween Interpolator.EASEBOTH
            ]
        }
    }
    override attribute effect = DropShadow {color: bind dsColor};
    
    override attribute content = [
        Rectangle { // Bounding Rect (for rollover)
            x: -WidgetToolbar.BUTTON_SIZE / 2, y: -WidgetToolbar.BUTTON_SIZE / 2
            width: WidgetToolbar.BUTTON_SIZE, height: WidgetToolbar.BUTTON_SIZE
            fill: Color.rgb(0, 0, 0, 0.0)
        },
        getShape()
    ];
    
    private attribute hover = false on replace {
        dsTimeline.start();
    }
    override attribute onMouseEntered = function(e) {
        hover = true;
    }
    override attribute onMouseExited = function(e) {
        hover = false;
    }
    
    private attribute pressed = false;
    override attribute onMousePressed = function(e) {
        pressed = true;
    }
    override attribute onMouseReleased = function(e:MouseEvent) {
        pressed = false;
        if (hover) {
            performAction();
        }
    }
}
