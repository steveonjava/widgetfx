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

import javafx.lang.Sequences;
import org.widgetfx.config.IntegerSequenceProperty;

/**
 * @author Stephen Chin
 * @author Keith Combs
 */
public class WidgetManager {
    
    private static attribute INITIAL_WIDGETS = [
        "../../widgets/Clock/dist/launch.jnlp",
        "../../widgets/SlideShow/dist/launch.jnlp",
        "../../widgets/WebFeed/dist/launch.jnlp"
    ];
    
    private static attribute instance = WidgetManager {}
    
    public static function getInstance() {
        return instance;
    }
    
    private attribute configuration = WidgetFXConfiguration.getInstanceWithProperties([
        IntegerSequenceProperty {
            name: "widgets"
            value: bind widgetIds with inverse
        }
    ]);

    private attribute updating:Boolean;

    private attribute widgetIds:Integer[] on replace [i..j]=newWidgetIds {
        if (not updating) {
            try {
                updating = true;
                widgets[i..j] = for (id in newWidgetIds) loadWidget(id);
            } finally {
                updating = false;
            }
        }
    }
    
    public attribute widgets:WidgetInstance[] = [] on replace [i..j]=newWidgets {
        if (not updating) {
            try {
                updating = true;
                widgetIds[i..j] = for (widget in newWidgets) widget.id;
            } finally {
                updating = false;
            }
        }
    }
    
    init {
        // todo - implement a widget security policy
        java.lang.System.setSecurityManager(null);
    }
    
    public function dockOffscreenWidgets() {
        for (instance in widgets) {
            instance.dockIfOffscreen();
        }
    }
    
    public function loadInitialWidgets() {
        for (url in INITIAL_WIDGETS) {
            addWidget(url);
        }
    }
    
    private function loadWidget(id:Integer):WidgetInstance {
        var instance = WidgetInstance{id: id};
        instance.load();
        return instance;
    }
    
    public function removeWidget(instance:WidgetInstance):Void {
        instance.deleteConfig();
        delete instance from widgets;
    }
    
    public function addWidget(jnlpUrl:String):WidgetInstance {
        for (widget in widgets) {
            if (widget.jnlpUrl.equals(jnlpUrl)) {
                // todo - notify the user that they tried to load a duplicate widget
                return null;
            }
        }
        var maxId = if (widgetIds.isEmpty()) 0 else (Sequences.max(widgetIds) as Integer).intValue();
        var instance = WidgetInstance{jnlpUrl: jnlpUrl, id: maxId + 1};
        insert instance into widgets;
        instance.load();
        return instance
    }
    
    public function getWidgetInstance(widget:Widget):WidgetInstance {
        var match = widgets[w|w.widget == widget];
        return match[0];
    }
    
    public function showConfigDialog(widget:Widget):Void {
        getWidgetInstance(widget).showConfigDialog();
    }

}
