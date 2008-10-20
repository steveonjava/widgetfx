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

import java.awt.Point;
import java.awt.Rectangle;
import javafx.lang.Sequences;
import javafx.scene.Group;
import javafx.scene.Node;
import javax.swing.SwingUtilities;

/**
 * @author Stephen Chin
 * @author Keith Combs
 */
public abstract class GapBox extends Group, Constrained {
    
    public static attribute UNBOUNDED = -1;
    
    public attribute spacing:Number on replace {
        impl_requestLayout();
    }
    
    override attribute maxWidth = 300;
    
    override attribute maxHeight = 300;
    
    protected attribute gapIndex:Integer = -1;
    
    public function getGapIndex() {
        return gapIndex;
    }
    
    public function containsScreenXY(screenX:Integer, screenY:Integer):Boolean {
        var point = new Point(screenX, screenY);
        SwingUtilities.convertPointFromScreen(point, impl_getSGNode().getPanel());
        impl_getSGNode().globalToLocal(point, point);
        return (new Rectangle(0, 0, maxWidth, maxHeight)).contains(new Point(point.x, point.y));
    }
    
    protected abstract function getBounds(index:Integer):Rectangle;
    
    private function getScreenBounds(index:Integer):Rectangle {
        var bounds = getBounds(index);
        var location = bounds.getLocation();
        impl_getSGNode().localToGlobal(location, location);
        SwingUtilities.convertPointToScreen(location, impl_getSGNode().getPanel());
        return new Rectangle(location.x, location.y, bounds.width, bounds.height);
    }
    
    public function getScreenBounds(node:Node):Rectangle {
        return getScreenBounds(Sequences.indexOf(content, node));
    }
    
    public function getGapScreenBounds():Rectangle {
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
