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

import java.lang.StringBuilder;
import java.math.BigInteger;
import java.util.Arrays;

/**
 * Property subclass to persist Integer sequences.
 *
 * @author Stephen Chin
 * @author Keith Combs
 */
public class IntegerSequenceProperty extends Property {
    /**
     * Integer sequence to be persisted.  To allow bijection of this property
     * bind it as follows:<blockquote><pre>
     * value: bind someVar with inverse
     * </blockquote></pre>
     */
    public attribute value:Integer[] on replace {
        fireOnChange();
    }
    
    /** {@inheritDoc} */
    public function getStringValue():String {
        var sb = new StringBuilder();
        for (s in value) {
            if (indexof s > 0) {
                sb.append(',');
            }
            sb.append(s);
        }
        return sb.toString();
    }
    
    /** {@inheritDoc} */
    public function setStringValue(value:String):Void {
        this.value = if (value.length() == 0) [] else for (s in Arrays.asList(value.split(","))) (new BigInteger(s)).intValue();
    }
}
