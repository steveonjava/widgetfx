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
package org.widgetfx.config;

import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.lang.*;
import java.util.Properties;

/**
 * Persistence of javafx fields to Property Files.
 *
 * Note: autoSave is disabled until the first save or load attempt to prevent overwriting of previously saved values.
 *
 * @author Stephen Chin
 * @author Keith Combs
 */
public class ConfigPersister {
    public attribute properties:Property[] on replace [i..j]=newProperties {
        for (property in newProperties) {
            property.onChange = changeListener;
        }
    }
    
    public attribute file:File;
    
    public attribute autoSave = false;
    
    public attribute mergeProperties = false;
    
    private attribute disableAutoSave = true;
    
    private attribute savedProperties:Properties;
    
    private function changeListener(changedProperty:Property):Void {
        if (not disableAutoSave and (autoSave or changedProperty.autoSave)) {
            save();
        }
    }
    
    private function validateRequiredAttributes() {
        if (file == null) {
            throw new IllegalStateException("File attribute is required but missing");
        }
        if (properties == null) {
            throw new IllegalStateException("Properties attribute is required but missing");
        }
    }
    
    public function load():Boolean {
        validateRequiredAttributes();
        disableAutoSave = true;
        try {
            if (file.exists() and properties != null) {
                savedProperties = Properties {};
                var reader = new FileReader(file);
                try {
                    savedProperties.load(reader);
                } finally {
                    reader.close();
                }
                // uses a counter/while loop so properties appended to the sequence are loaded
                var i = 0;
                while (i < properties.size()) {
                    var property = properties[i++];
                    if (savedProperties.containsKey(property.name)) {
                        property.setStringValue(savedProperties.get(property.name) as String);
                    }
                }
                return true;
            }
        } finally {
            disableAutoSave = false;
            if (not mergeProperties) {
                savedProperties = null;
            }
        }
        return false;
    }
    
    public function save() {
        validateRequiredAttributes();
        disableAutoSave = false;
        if (properties != null) {
            if (not mergeProperties or savedProperties == null) {
                savedProperties = Properties {};
            }
            for (property in properties) {
                savedProperties.put(property.name, property.getStringValue());
            }
            file.getParentFile().mkdirs();
            file.createNewFile();
            var writer = new FileWriter(file);
            try {
                savedProperties.store(writer, null);
            } finally {
                writer.close();
            }
        }
    }
}
