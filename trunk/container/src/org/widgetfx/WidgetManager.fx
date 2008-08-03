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

import javax.jnlp.*;
import org.widgetfx.config.Configuration;
import java.net.URL;

/**
 * @author Stephen Chin
 * @author kcombs
 */
public class WidgetManager {
    
    private static attribute instance = WidgetManager {}
    
    public attribute widgets:WidgetInstance[] = [];
    
    public static function getInstance() {
        return instance;
    }

    public function loadWidgets():Void {
        // todo - implement a widget security policy
        java.lang.System.setSecurityManager(null);

//        WidgetInstance{className: "org.widgetfx.widget.Clock", id: 0},
        addWidget(["../../widgets/SlideShow/dist/SlideShow.jar"], "org.widgetfx.widget.SlideShow");
//        WidgetInstance{className: "org.widgetfx.widget.WebFeed", id: 2}
    }
    
    public function addWidget(jarPaths:String[], className:String):WidgetInstance {
        var bs = ServiceManager.lookup("javax.jnlp.BasicService") as BasicService;
        var ds = ServiceManager.lookup("javax.jnlp.DownloadService") as DownloadService;
        for (path in jarPaths) {
            var url = new URL(bs.getCodeBase(), path); 
            // reload the resource into the cache 
            var dsl = ds.getDefaultProgressWindow(); 
            ds.loadResource(url, null, dsl);
        }
        var instance = WidgetInstance{className: className, id: 1};
        insert instance into widgets;
        if (instance.widget.configuration != null) {
            instance.widget.configuration.load();
        }
        return instance;
    }
    
    public function getIdForConfig(config:Configuration):Integer {
        var match = widgets[w|w.widget.configuration == config];
        return match[0].id;
    }

}
