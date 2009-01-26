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

import java.io.File;
import java.lang.System;
import java.net.URL;
import javax.jnlp.BasicService;
import javax.jnlp.ServiceManager;
import org.widgetfx.WidgetManager;
import org.widgetfx.config.*;

/**
 * @author Stephen Chin
 * @author Keith Combs
 */
public def PUBLIC_CODEBASE = "http://widgetfx.org/dock/";
public def VERSION = "1.0.4";
public def IS_MAC = System.getProperty("os.name").contains("Mac OS");
public def IS_VISTA = System.getProperty("os.name").contains("Vista");
public var TRANSPARENT = true;

var instance = WidgetFXConfiguration {}

public function getInstanceWithProperties(properties:Property[]) {
    insert properties into instance.properties;
    return instance;
}

public function getInstance() {
    return instance;
}

public class WidgetFXConfiguration {
    
    var properties:Property[] = [];
    
    public var mergeProperties = false;
    
    public-read var codebase = (ServiceManager.lookup("javax.jnlp.BasicService") as BasicService).getCodeBase();
    
    public-read var devMode = codebase.getProtocol().equalsIgnoreCase("file") or (codebase.getHost().equalsIgnoreCase("localhost") and codebase.getPort() == 8082) on replace {
        if (devMode) {
            println("Starting Development Mode");
        }
    }

    public-read var configFolder = new File(System.getProperty("user.home"),
        if (devMode) ".WidgetFXDev" else ".WidgetFX") on replace {
        println("Configuration directory location is: \"{configFolder}\"");
    }
    
    function getPropertyFile():File {
        var configPath = new File(configFolder, "WidgetFX.config");
        return configPath;
    }
    
    var persister = ConfigPersister {
        file: getPropertyFile()
        properties: bind properties
        autoSave: true
        mergeProperties: bind mergeProperties
    }
    
    public function load() {
        if (not persister.load()) {
            WidgetManager.getInstance().loadInitialWidgets();
        }
        // save any properties that may have changed during load
        persister.save();
    }
    
    public function save() {
        persister.save();
    }
}
