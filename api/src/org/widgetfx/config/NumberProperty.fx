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
package org.widgetfx.config;

import java.math.BigDecimal;

/**
 * Property subclass to persist Number primitives.
 *
 * @author Stephen Chin
 * @author Keith Combs
 */
public class NumberProperty extends Property {
    /**
     * Number value to be persisted.  To allow bijection of this property
     * bind it as follows:<blockquote><pre>
     * value: bind someVar with inverse
     * </blockquote></pre>
     */
    public attribute value:Number on replace {
        fireOnChange();
    }
    
    /** {@inheritDoc} */
    public function getStringValue():String {
        return value.toString();
    }
    
    /** {@inheritDoc} */
    public function setStringValue(value:String):Void {
        this.value = (new BigDecimal(value)).doubleValue();
    }
}
