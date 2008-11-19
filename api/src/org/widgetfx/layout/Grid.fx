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

import java.lang.Math;
import javafx.scene.*;
import javafx.scene.layout.*;

/**
 * @author Stephen Chin
 * @author Keith Combs
 */
public class Grid extends Container {
    public var growRows:Integer[];
    
    public var growColumns:Integer[];
    
    var columnPreferred:Number[] = [0, 0, 0, 0, 0, 0, 0, 0];
    
    var rowPreferred:Number[] = [0, 0, 0, 0, 0, 0, 0, 0];
    
    public var rows:Row[] on replace {
        for (row in rows) {
            for (cell in row.cells) {
                var node:Node = if (cell instanceof Cell) {
                    (cell as Cell).content
                } else {
                    cell as Node
                }
                columnPreferred[indexof cell] = Math.max(columnPreferred[indexof cell], node.boundsInLocal.width);
                rowPreferred[indexof row] = Math.max(rowPreferred[indexof row], node.boundsInLocal.width);
            }
        }
    }
    
    override var content = bind getContent(rows);
    
    bound function getContent(rows:Row[]) {
        return for (row in rows) {
            for (cell in row.cells) {
                if (cell instanceof Cell) {
                    (cell as Cell).content
                } else {
                    cell as Node
                }
            }
        }
    }
    
    init {
        impl_layout = doGridLayout;
    }

    function doGridLayout(g:Group):Void {
        var x:Number = 0;
        var y:Number = 0;
        for (row in rows) {
            for (cell in row.cells) {
                var node:Node = if (cell instanceof Cell) {
                    (cell as Cell).content
                } else {
                    cell as Node
                }                
                node.impl_layoutX = x;
                node.impl_layoutY = y;
                x += columnPreferred[indexof cell];
            }
            x = 0;
            y += rowPreferred[indexof row];
        }
    }
}
