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
    public var properties:Property[] on replace [i..j]=newProperties {
        for (property in newProperties) {
            property.onChange = changeListener;
        }
    }
    
    public var file:File;
    
    public-init var autoSave = false;
    
    public var mergeProperties = false;
    
    var disableAutoSave = true;
    
    var savedProperties:Properties;
    
    function changeListener(changedProperty:Property):Void {
        if (not disableAutoSave and (autoSave or changedProperty.autoSave)) {
            save();
        }
    }
    
    function validateRequiredAttributes() {
        if (file == null) {
            throw new IllegalStateException("File var is required but missing");
        }
        if (properties == null) {
            throw new IllegalStateException("Properties var is required but missing");
        }
    }
    
    public function load():Boolean {
        validateRequiredAttributes();
        if (file.exists() and properties != null) {
            savedProperties = Properties {};
            var reader = new FileReader(file);
            try {
                savedProperties.load(reader);
            } finally {
                reader.close();
            }
            load(savedProperties);
            if (not mergeProperties) {
                savedProperties = null;
            }
            return true;
        }
        return false;
    }

    public function load(savedProperties:Properties) {
        disableAutoSave = true;
        try {
            // uses a counter/while loop so properties appended to the sequence are loaded
            var i = 0;
            while (i < properties.size()) {
                var property = properties[i++];
                if (savedProperties.containsKey(property.name)) {
                    property.setStringValue(savedProperties.get(property.name) as String);
                }
            }
        } finally {
            disableAutoSave = false;
        }
    }
    
    public function save() {
        validateRequiredAttributes();
        disableAutoSave = false;
        if (properties != null) {
            if (not mergeProperties or savedProperties == null) {
                savedProperties = Properties {};
            }
            save(savedProperties);
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

    public function save(savedProperties:Properties) {
        for (property in properties) {
            savedProperties.put(property.name, property.getStringValue());
        }
    }
}
