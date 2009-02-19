/*
 * WidgetFX - JavaFX Desktop Widget Platform
 * Copyright (c) 2008-2009, WidgetFX Group
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 1. Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 * 3. Neither the name of WidgetFX nor the names of its contributors may be used
 *    to endorse or promote products derived from this software without
 *    specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */
package org.widgetfx.layout;

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
