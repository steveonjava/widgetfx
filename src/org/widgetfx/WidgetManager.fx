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

import org.widgetfx.config.Configuration;

/**
 * @author Stephen Chin
 * @author kcombs
 */
public class WidgetManager {
    
    private static attribute instance = WidgetManager {}
    
    public attribute widgets:WidgetInstance[];
    
    public static function getInstance() {
        return instance;
    }

    public function loadWidgets():Void {
        widgets = [
            WidgetInstance{className: "org.widgetfx.widget.Clock", id: 0},
            WidgetInstance{className: "org.widgetfx.widget.SlideShow", id: 1},
            WidgetInstance{className: "org.widgetfx.widget.WebFeed", id: 2}
        ];
        for (instance in widgets where instance.widget.configuration <> null) {
            instance.widget.configuration.load();
        }
    }
    
    public function getIdForConfig(config:Configuration):Integer {
        return widgets[w|w.widget.configuration == config][0].id;
    }

}
