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
package org.widgetfx;

import java.lang.Class;
import com.sun.javafx.runtime.sequence.Sequence;
import com.sun.javafx.runtime.sequence.Sequences;
import com.sun.javafx.runtime.Entry;

/**
 * @author Stephen Chin
 * @author Keith Combs
 */
public class WidgetInstance {
    public attribute className:String on replace {
        var widgetClass:Class = Class.forName(className);
        var name = Entry.entryMethodName();
        var args = Sequences.make(java.lang.String.<<class>>) as java.lang.Object;
        widget = widgetClass.getMethod(name, Sequence.<<class>>).invoke(null, args) as Widget;
    };
    
    public attribute id:Integer;
    
    public attribute widget:Widget;
}
