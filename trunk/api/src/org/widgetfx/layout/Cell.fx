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
package org.widgetfx.layout;

import javafx.scene.Node;

/**
 * @author Stephen Chin
 * @author Keith Combs
 */
public class Cell {
    public-init var rowSpan:Integer;
    public-init var columnSpan:Integer;
    public-init var verticalAlignment:VerticalAlignment = VerticalAlignment.CENTER;
    public-init var horizontalAlignment:HorizontalAlignment = HorizontalAlignment.LEFT;
    public-init var verticalGrow:Integer;
    public-init var horizontalGrow:Integer;
    public-init var maximumHeight:Number = -1;
    public-init var maximumWidth:Number = -1;
    public-init var minimumHeight:Number = -1;
    public-init var minimumWidth:Number = -1;
    public-init var preferredHeight:Number = -1;
    public-init var preferredWidth:Number = -1;
    public-init var content:Node;
}
