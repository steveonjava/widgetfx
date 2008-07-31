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

import org.widgetfx.WidgetManager;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.lang.System;
import java.util.Properties;
import javafx.application.Dialog;
import javafx.application.Stage;
import javafx.ext.swing.Component;
import javafx.ext.swing.ComponentView;
import javafx.ext.swing.BorderPanel;
import javafx.ext.swing.Button;
import javafx.scene.HorizontalAlignment;
import javafx.ext.swing.FlowPanel;

/**
 * @author Stephen Chin
 * @author kcombs
 */
public class Configuration {
    public attribute component:Component;
    
    public attribute properties:Property[];
    
    public attribute onLoad:function();
    
    public attribute onSave:function();
    
    public attribute onCancel:function();
    
    private function getPropertyFile():File {
        var id = WidgetManager.getInstance().getIdForConfig(this);
        var home = System.getProperty("user.home");
        return new File(home, ".WidgetFX/{id}.config");
    }
    
    public function load() {
        var propertyFile = getPropertyFile();
        if (propertyFile.exists() and properties <> null) {
            var savedProperties = Properties {};
            var reader = new FileReader(propertyFile);
            try {
                savedProperties.load(reader);
            } finally {
                reader.close();
            }
            for (property in properties) {
                if (savedProperties.containsKey(property.name)) {
                    property.setStringValue(savedProperties.get(property.name) as String);
                }
            }
        }
        if (onLoad <> null) {
            onLoad();
        }
    }
    
    public function save() {
        var propertyFile = getPropertyFile();
        if (properties <> null) {
            var savedProperties = Properties {};
            for (property in properties) {
                savedProperties.put(property.name, property.getStringValue());
            }
            propertyFile.getParentFile().mkdirs();
            propertyFile.createNewFile();
            var writer = new FileWriter(propertyFile);
            try {
                savedProperties.store(writer, null);
            } finally {
                writer.close();
            }
        }
        if (onSave <> null) {
            onSave();
        }
    }
    
    public function cancel() {
        if (onCancel <> null) {
            onCancel();
        }
    }
    
    public function showDialog() {
        var configDialog:Dialog = Dialog {
            stage: Stage {
                content: [
                    ComponentView {
                        component: BorderPanel {
                            center: component
                            bottom: FlowPanel {
                                alignment: HorizontalAlignment.RIGHT
                                content: [
                                    Button {
                                        text: "Save"
                                        action: function() {
                                            save();
                                            configDialog.close();
                                        }
                                    },
                                    Button {
                                        text: "Cancel"
                                        action: function() {
                                            cancel();
                                            configDialog.close();
                                        }
                                    }
                                ]
                            }
                        }
                    }
                ]
            }
            visible: true
        }
    }
}
