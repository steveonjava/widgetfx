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
        impl_requestLayout();
    }
    
    override var maxWidth = 300 on replace {
        impl_requestLayout();
    }
    
    override var maxHeight = 300 on replace {
        impl_requestLayout();
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
        java.lang.System.out.println("sceneX: {sceneCoord.x}, sceneY: {sceneCoord.y}, scene.x: {scene.x}, scene.y: {scene.y}, scene.stage.x: {scene.stage.x}, scene.stage.y: {scene.stage.y}");
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
    
    public function doLayout():Void {
        impl_layout(this);
    }
}
