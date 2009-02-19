/*
 * WidgetFX - JavaFX Desktop Widget Platform
 * Copyright (c) 2008-2009, WidgetFX Group
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 1. Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 * 3. Neither the name of WidgetFX nor the names of its contributors may be used
 *    to endorse or promote products derived from this software without
 *    specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
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
