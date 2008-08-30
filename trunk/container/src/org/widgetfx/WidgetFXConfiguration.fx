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

import org.widgetfx.WidgetManager;
import org.widgetfx.config.*;
import java.lang.System;
import java.io.File;

/**
 * @author Stephen Chin
 * @author Keith Combs
 */
public class WidgetFXConfiguration {
    
    private static attribute instance = WidgetFXConfiguration {}
    
    public static function getInstance() {
        return instance;
    }
    
    public attribute properties:Property[] = [];

    public static function getInstanceWithProperties(properties:Property[]) {
        insert properties into instance.properties;
        return instance;
    }
    
    private function getPropertyFile():File {
        var home = System.getProperty("user.home");
        return new File(home, ".WidgetFX/WidgetFX.config");
    }
    
    private attribute persister = ConfigPersister {
        file: getPropertyFile()
        properties: bind properties
        autoSave: true
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
