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
import javafx.scene.Group;
import javafx.scene.Node;
import javafx.util.Sequences;
import javax.swing.SwingUtilities;

/**
 * @author Stephen Chin
 * @author Keith Combs
 */
public var UNBOUNDED = -1;

public abstract class GapBox extends Group, Constrained {
    
    public-init var spacing:Number on replace {
        requestLayout();
    }
    
    override var maxWidth = 300 on replace {
        requestLayout();
    }
    
    override var maxHeight = 300 on replace {
        requestLayout();
    }
    
    protected var gapIndex:Integer = -1;
    
    public function getGapIndex() {
        return gapIndex;
    }
    
    protected function screenToLocal(screenX:Integer, screenY:Integer):Point2D {
        return sceneToLocal(screenX - scene.x - scene.stage.x, screenY - scene.y - scene.stage.y);
    }
    
    protected function localToScreen(localX:Integer, localY:Integer):Point2D {
        var sceneCoord = localToScene(localX, localY);
        return Point2D {
            x: sceneCoord.x + scene.x + scene.stage.x
            y: sceneCoord.y + scene.y + scene.stage.y
        }
    }
    
    public function containsScreenXY(screenX:Integer, screenY:Integer):Boolean {
        return Rectangle2D {
            minX: 0, minY: 0, width: maxWidth, height: maxHeight
        }.contains(screenToLocal(screenX, screenY));
    }
    
    protected abstract function getBounds(index:Integer):Rectangle2D;
    
    function getScreenBounds(index:Integer):Rectangle2D {
        var bounds = getBounds(index);
        var location = localToScreen(bounds.minX, bounds.minY);
        return Rectangle2D {
            minX: location.x
            minY: location.y
            width: bounds.width
            height: bounds.height
        }
    }
    
    public function getScreenBounds(node:Node):Rectangle2D {
        return getScreenBounds(Sequences.indexOf(content, node));
    }
    
    public function getGapScreenBounds():Rectangle2D {
        return getScreenBounds(gapIndex);
    }
    
    public function clearGap(animate:Boolean):Void {
        setGap(-1, -1, animate);
    }
    
    public abstract function setGap(screenX:Integer, screenY:Integer, size:Number, animate:Boolean):Void;
    
    public abstract function setGap(index:Integer, size:Number, animate:Boolean):Void;

}
