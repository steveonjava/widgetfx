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
        return Rectangle2D {
            minX: 0
            minY: y
            width: maxWidth
            height: gapHeight
        }
    }

    override function setGap(screenX:Integer, screenY:Integer, size:Number, animate:Boolean):Void {
        var point = screenToLocal(screenX, screenY);
        var index = content.size();
        for (node in content) {
            var viewY = node.boundsInParent.minY;
            var viewHeight = node.boundsInParent.height;
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
                        var newX = x;
                        var newY = y;
                        var values = [
                            node.impl_layoutX => newX tween Interpolator.EASEIN,
                            node.impl_layoutY => newY tween Interpolator.EASEIN
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
