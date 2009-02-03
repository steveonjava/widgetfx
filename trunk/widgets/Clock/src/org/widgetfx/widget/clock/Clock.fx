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
package org.widgetfx.widget.clock;

import java.lang.Math.*;
import javafx.scene.shape.*;
import org.widgetfx.*;

/**
 * @author Stephen Chin
 */
public class Clock extends Widget {
    override var width = 105;
    override var height = 105;
    override var resizable = false;
    override var skin = ClockSkin {}
    override var clip = Circle {
        centerX: bind width / 2, centerY: bind height / 2, radius: bind min(width, height) / 2
    }
}
