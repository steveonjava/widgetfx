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
 * Properties are persistent entities that are persisted between program
 * invocations.  There are Property subclasses for all the JavaFX basic types
 * (excluding Duration) as well as Sequences of basic types.
 * <p>
 * By default properties bound to a {@link Configuration} are only persisted when the
 * user clicks "Save" in the dialog.  However, if a Property has "autoSave"
 * enabled it will be persisted any time its state changes, which allows
 * application-driven state to be saved in addition to user state.
 *
 * @author Stephen Chin
 * @author Keith Combs
 */
public abstract class Property {
    /**
     * Name of the property as it will be saved to the configuration file.  This
     * must be given a unique value.
     */
    public attribute name:String;
    
    /**
     * If set to true, the state of this propery will be persisted whenever the
     * value changes.  The default is false so that unnecessary state persistence
     * is not performed.
     */
    public attribute autoSave:Boolean;

    /**
     * Implemented by subclasses to provide conversion of values to a common
     * String representation.
     */
    public abstract function getStringValue():String;
    
    /**
     * Implemented by subclasses to provide conversion of values from a common
     * String representation.
     */
    public abstract function setStringValue(value:String):Void;
    
    attribute onChange:function(changedProperty:Property):Void;
    
    private function fireOnChange() {
        if (onChange != null) {
            onChange(this);
        }
    }
}
