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

import java.awt.*;
import java.awt.event.*;

/**
 * @author Stephen Chin
 */
public class NativeCheckboxMenuItem extends NativeMenuItem {
    public var selected:Boolean on replace {
        getCheckboxMenuItem().setState(selected);
    }
    
    public function getCheckboxMenuItem():CheckboxMenuItem {
        return getMenuItem() as CheckboxMenuItem;
    }
    
    postinit {
        getCheckboxMenuItem().addItemListener(ItemListener {
            override function itemStateChanged(e:ItemEvent):Void {
                selected = e.getStateChange() == ItemEvent.SELECTED;
            }
        });
    }

    override function createMenuItem():MenuItem {
        return CheckboxMenuItem{};
    }
}
