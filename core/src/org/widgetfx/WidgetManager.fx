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
    
    public attribute widgets:WidgetInstance[];
    
    public static function getInstance() {
        return instance;
    }

    public function loadWidgets():Void {
        var ds = ServiceManager.lookup("javax.jnlp.DownloadService") as DownloadService; 
        // determine if a particular resource is cached
        var url = new URL("file:/C:/prog/WidgetFXWeb/trunk/widgets/SlideShow/dist/SlideShow.jar"); 
        // reload the resource into the cache 
//        var dsl = ds.getDefaultProgressWindow(); 
        ds.loadResource(url, null, DownloadServiceListener {
                function downloadFailed(url, version) {
                    java.lang.System.out.println("download failed");
                }
                function progress(url, version, readSoFar, total, overallPercent) {
                    java.lang.System.out.println("progress: {overallPercent}");
                }
                function upgradingArchive(url, version, patchPercent, overallPercent) {
                    java.lang.System.out.println("upgradingArchive");
                }
                function validating(url, version, entry, total, overallPercent) {
                    java.lang.System.out.println("validating");
                }
        }); 

        widgets = [
            WidgetInstance{className: "org.widgetfx.widget.Clock", id: 0},
            WidgetInstance{className: "org.widgetfx.widget.SlideShow", id: 1},
            WidgetInstance{className: "org.widgetfx.widget.WebFeed", id: 2}
        ];
        for (instance in widgets where instance.widget.configuration != null) {
            instance.widget.configuration.load();
        }
    }
    
    public function getIdForConfig(config:Configuration):Integer {
        var match = widgets[w|w.widget.configuration == config];
        return match[0].id;
    }

}
