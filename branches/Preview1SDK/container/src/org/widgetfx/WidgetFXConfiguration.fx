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
package org.widgetfx;

import java.io.File;
import java.lang.System;
import java.net.URL;
import javafx.scene.image.*;
import javax.jnlp.BasicService;
import javax.jnlp.ServiceManager;
import org.widgetfx.WidgetManager;
import org.widgetfx.config.*;

/**
 * @author Stephen Chin
 * @author Keith Combs
 */
public class WidgetFXConfiguration {
    public static attribute VERSION = "0.1.9";
    public static attribute TRANSPARENT = true;
    public static attribute IS_MAC = System.getProperty("os.name").contains("Mac OS");
    public static attribute IS_VISTA = System.getProperty("os.name").contains("Vista");
    
    private static attribute instance = WidgetFXConfiguration {}
    
    public static function getInstance() {
        return instance;
    }
    
    public attribute properties:Property[] = [];
    
    public attribute mergeProperties = false;
    
    public attribute widgetFXIcon16 = Image {url: getClass().getResource("nut9_16.png").toString()};
    public attribute widgetFXIcon16s = Image {url: getClass().getResource("nut9_16s.png").toString()};
    public attribute widgetFXIcon16t = Image {url: getClass().getResource("nut9_16s.gif").toString()};
    
    public attribute codebase = (ServiceManager.lookup("javax.jnlp.BasicService") as BasicService).getCodeBase();
    
    public attribute devMode = codebase.getProtocol().equalsIgnoreCase("file") on replace {
        if (devMode) {
            System.out.println("Starting Development Mode");
        }
    }

    public attribute configFolder = new File(System.getProperty("user.home"),
        if (devMode) ".WidgetFXDev" else ".WidgetFX") on replace {
        System.out.println("Configuration directory location is: \"{configFolder}\"");
    }
    
    public static function getInstanceWithProperties(properties:Property[]) {
        insert properties into instance.properties;
        return instance;
    }
    
    private function getPropertyFile():File {
        var configPath = new File(configFolder, "WidgetFX.config");
        return configPath;
    }
    
    private attribute persister = ConfigPersister {
        file: getPropertyFile()
        properties: bind properties
        autoSave: true
        mergeProperties: bind mergeProperties
    }
    
    public function load() {
        if (not persister.load()) {
            WidgetManager.getInstance().loadInitialWidgets();
            persister.save(); // initial save
        }
    }
    
    public function save() {
        persister.save();
    }
}
