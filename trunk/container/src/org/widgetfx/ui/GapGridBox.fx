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

import javafx.animation.Timeline;
import javafx.animation.KeyFrame;
import javafx.animation.Interpolator;
import javafx.geometry.*;
import javafx.scene.Group;
import javafx.scene.Node;
import javax.swing.SwingUtilities;

/**
 * @author Stephen Chin
 * @author Keith Combs
 */
public class GapGridBox extends GapBox {
    
    public-init var rows:Integer = 1;

    public-init var columns:Integer = 1;
    
    var nodeWidth = bind (maxWidth - (columns - 1) * spacing) / columns;
    
    var nodeHeight = bind (maxHeight - (rows - 1) * spacing) / rows;
    
    var timeline:Timeline;

    override function getBounds(index:Integer):Rectangle2D {
        return Rectangle2D {
            minX: (index mod columns) * (nodeWidth + spacing)
            minY: index / columns * (nodeHeight + spacing)
            width: nodeWidth
            height: nodeHeight
        };
    }
    
    override function setGap(screenX:Integer, screenY:Integer, size:Number, animate:Boolean):Void {
        var point = screenToLocal(screenX, screenY);
        var xCell = (point.x * columns / maxWidth).intValue();
        var yCell = (point.y * rows / maxHeight).intValue();
        var index = yCell * columns + xCell;
        if (index > content.size()) {
            index = content.size();
        }
        setGap(index, size, animate);
    }
    
    /**
     * Set the index and size of the gap.  The gap will get inserted before the component at this index.
     * The actual gap size will also include spacing if it is set.
     */
    override function setGap(index:Integer, size:Number, animate:Boolean):Void {
        if (gapIndex != index) {
            gapIndex = index;
            impl_requestLayout();
        }
    }
    
    init {
        impl_layout = doGapGridLayout;
    }

    function doGapGridLayout(g:Group):Void {
        if (timeline.running) {
            return;
        }
        var x:Number = 0;
        var y:Number = 0;
        var gap = 0;
        for (node in content where node.visible) {
            if (node instanceof Constrained) {
                var constrained = node as Constrained;
                constrained.maxWidth = nodeWidth;
                constrained.maxHeight = nodeHeight;
            }
            if (indexof node == gapIndex) {
                if (indexof node mod columns == columns - 1) {
                    x = 0;
                    y += nodeHeight + spacing;
                } else {
                    x += nodeWidth + spacing;
                }
                gap = 1;
            }
            node.impl_layoutX = x;
            node.impl_layoutY = y;
            if ((indexof node + gap) mod columns == columns - 1) {
                x = 0;
                y += nodeHeight + spacing;
            } else {
                x += nodeWidth + spacing;
            }
        }
    }

}
