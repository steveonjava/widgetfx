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
import javafx.animation.*;
import javafx.scene.*;
import javafx.scene.effect.*;
import javafx.scene.input.*;
import javafx.scene.shape.*;
import javafx.scene.paint.*;

/**
 * @author Stephen Chin
 * @author Keith Combs
 */
var pressedColor = Color.rgb(54, 101, 143);

public abstract class ToolbarButton extends Group {
    public-init var toolbar:WidgetToolbar;

    public-init protected var name:String;
    
    protected abstract function performAction():Void;

    protected abstract function getShape():Node[];

    protected var highlightColor = bind if (hover and pressed) pressedColor else Color.WHITE;
    
    var dsColor = Color.BLACK;
    var dsTimeline = Timeline {
        keyFrames: KeyFrame {
            time: 300ms
            values: [
                dsColor => Color.WHITE tween Interpolator.EASEBOTH
            ]
        }
    }
    
    override var hover on replace {
        dsTimeline.rate = if (hover) 1 else -1;
        dsTimeline.play();
        toolbar.setName(if (hover) then name else "");
    }
    
    override var onMouseReleased = function(e:MouseEvent) {
        if (hover) {
            performAction();
        }
    }
    
    init {
        effect = DropShadow {color: bind dsColor};
        content = [
            Rectangle { // Bounding Rect (for rollover)
                x: -WidgetToolbar.BUTTON_SIZE / 2, y: -WidgetToolbar.BUTTON_SIZE / 2
                width: WidgetToolbar.BUTTON_SIZE, height: WidgetToolbar.BUTTON_SIZE
                fill: Color.rgb(0, 0, 0, 0.0)
            },
            getShape()
        ];
    }
}
