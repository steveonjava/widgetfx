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

 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
package org.widgetfx.config;

/**
 * @author Stephen Chin
 * @author Keith Combs
 */
public abstract class Property {
    public attribute name:String;
    
    public attribute autoSave:Boolean;
    
    public abstract function getStringValue():String;
    
    public abstract function setStringValue(value:String):Void;
    
    attribute onChange:function(changedProperty:Property):Void;
    
    private function fireOnChange() {
        if (onChange != null) {
            onChange(this);
        }
    }
}
