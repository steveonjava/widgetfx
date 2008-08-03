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

import java.lang.Class;
import com.sun.javafx.runtime.sequence.Sequence;
import com.sun.javafx.runtime.sequence.Sequences;
import com.sun.javafx.runtime.Entry;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.lang.System;
import java.util.Properties;
import javafx.application.Dialog;
import javafx.application.Stage;
import javafx.ext.swing.ComponentView;
import javafx.ext.swing.BorderPanel;
import javafx.ext.swing.Button;
import javafx.scene.HorizontalAlignment;
import javafx.ext.swing.FlowPanel;

/**
 * @author Stephen Chin
 * @author Keith Combs
 */
public class WidgetInstance {
    public attribute mainClass:String on replace {
        try {
            var widgetClass:Class = Class.forName(mainClass);
            var name = Entry.entryMethodName();
            var args = Sequences.make(java.lang.String.<<class>>) as java.lang.Object;
            widget = widgetClass.getMethod(name, Sequence.<<class>>).invoke(null, args) as Widget;
        } catch (e:java.lang.RuntimeException) {
            e.printStackTrace();
        }
    };

    public attribute id:Integer;
    
    public attribute widget:Widget;
    
    private function getPropertyFile():File {
        var home = System.getProperty("user.home");
        return new File(home, ".WidgetFX/{id}.config");
    }
    
    public function load() {
        if (widget.onStart != null) widget.onStart();
        if (widget.configuration != null) {
            var propertyFile = getPropertyFile();
            if (propertyFile.exists() and widget.configuration.properties != null) {
                var savedProperties = Properties {};
                var reader = new FileReader(propertyFile);
                try {
                    savedProperties.load(reader);
                } finally {
                    reader.close();
                }
                for (property in widget.configuration.properties) {
                    if (savedProperties.containsKey(property.name)) {
                        property.setStringValue(savedProperties.get(property.name) as String);
                    }
                }
            }
            if (widget.configuration.onLoad != null) {
                widget.configuration.onLoad();
            }
        }
    }
    
    public function save() {
        if (widget.configuration != null) {
            var propertyFile = getPropertyFile();
            if (widget.configuration.properties != null) {
                var savedProperties = Properties {};
                for (property in widget.configuration.properties) {
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
            if (widget.configuration.onSave != null) {
                widget.configuration.onSave();
            }
        }
    }
    
    public function cancel() {
        if (widget.configuration != null) {
            if (widget.configuration.onCancel != null) {
                widget.configuration.onCancel();
            }
        }
    }
    
    public function showConfigDialog():Void {
        if (widget.configuration != null) {
            var configDialog:Dialog = Dialog {
                title: "{widget.name} Configuration"
                stage: Stage {
                    content: [
                        ComponentView {
                            component: BorderPanel {
                                center: widget.configuration.component
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
}
