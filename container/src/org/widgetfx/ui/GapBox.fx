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

import javafx.scene.Group;

/**
 * @author Stephen Chin
 * @author Keith Combs
 */
public abstract class GapBox extends Group {
    
    public static attribute UNBOUNDED = -1;
    
    public attribute width:Integer = 300;
    
    public attribute height:Integer = 300;
    
    public attribute nodeWidth:Number = UNBOUNDED;
    
    public attribute nodeHeight:Number = UNBOUNDED;
    
    private attribute gapIndex:Integer;
    
    private attribute gapSize:Number;
    
    public function getGapIndex():Integer {
        return gapIndex;
    }

    public function getGapSize():Number {
        return gapSize;
    }
    
    public abstract function getGapLocation():Number;
    
    public abstract function clearGap(animate:Boolean):Void;
    
    public abstract function setGap(index:Integer, size:Number, animate:Boolean):Void;
}
