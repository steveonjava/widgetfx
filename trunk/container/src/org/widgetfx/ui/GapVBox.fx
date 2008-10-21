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

import com.sun.scenario.scenegraph.SGNode;
import com.sun.scenario.scenegraph.SGGroup;
import javafx.geometry.*;
import javafx.animation.Timeline;
import javafx.animation.KeyFrame;
import javafx.animation.Interpolator;
import javafx.scene.*;
import javax.swing.SwingUtilities;

/**
 * @author Stephen Chin
 * @author Keith Combs
 */
public class GapVBox extends GapBox {
    
    var gapHeight:Number;
        
    var timeline:Timeline;

    override function getBounds(index:Integer):Rectangle2D {
        var y:Number = 0;
        for (node in content) {
            if (indexof node == gapIndex) {
                if (gapIndex == index) {
                    return Rectangle2D {
                        minX: 0
                        minY: y
                        width: maxWidth
                        height: gapHeight
                    }
                }
                y += gapHeight;
            }
            if (indexof node == index) {
                return Rectangle2D {
                    minX: 0
                    minY: y
                    width: maxWidth
                    height: node.boundsInLocal.height
                }
            }
            if (node.visible) {
                y += node.boundsInLocal.height + spacing;
            }
        }
        return null;
    }

    override function setGap(screenX:Integer, screenY:Integer, size:Number, animate:Boolean):Void {
        var point = screenToLocal(screenX, screenY);
        var index = content.size();
        for (node in content) {
            var viewY = node.boundsInLocal.minY;
            var viewHeight = node.boundsInLocal.height;
            if (point.y < viewY + viewHeight / 2) {
                index = indexof node;
                break;
            }
        }
        setGap(index, size, animate);
    }
    
    /**
     * Set the index and size of the gap.  The gap will get inserted before the component at this index.
     * The actual gap size will also include spacing if it is set.
     */
    override function setGap(index:Integer, size:Number, animate:Boolean):Void {
        var adjustedSize = if (size == -1) 0 else size + spacing;
        if (gapIndex != index or gapHeight != adjustedSize) {
            gapIndex = index;
            gapHeight = adjustedSize;
            if (animate) {
                animateGapVBoxLayout();
            } else {
                timeline.stop();
                impl_requestLayout();
            }
        }
    }
    
    init {
        impl_layout = doGapVBoxLayout;
    }

    function doGapVBoxLayout(g:Group):Void {
        if (timeline.running) {
            return;
        }
        var x:Number = 0;
        var y:Number = 0;
        for (node in content) {
            if (node instanceof Constrained) {
                var constrained = node as Constrained;
                constrained.maxWidth = maxWidth;
                constrained.maxHeight = Constrained.UNBOUNDED;
            }
            if (indexof node == gapIndex) {
                y += gapHeight;
            }
            if (node.visible) {
                node.impl_layoutX = x;
                node.impl_layoutY = y;
                y += node.boundsInLocal.height + spacing;
            }
        }
    }

    function animateGapVBoxLayout():Void {
        if (timeline != null) {
            timeline.pause();
        }
        var x:Number = 0;
        var y:Number = 0;
        var newTimeline = Timeline {
            keyFrames: KeyFrame {
                time: 500ms
                values: for (node in content) {
                    if (indexof node == gapIndex) {
                        y += gapHeight;
                    }
                    if (node.visible) {
                        var values = [
                            node.impl_layoutX => x tween Interpolator.EASEIN,
                            node.impl_layoutY => y tween Interpolator.EASEIN
                        ];
                        y += node.boundsInLocal.height + spacing;
                        values;
                    } else {
                        [];
                    }
                }
                action: function() {
                    impl_requestLayout();
                }
            }
        }
        newTimeline.play();
        timeline = newTimeline;
    }
}
