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
import org.widgetfx.config.ConfigPersister;
import com.sun.javafx.runtime.sequence.Sequence;
import com.sun.javafx.runtime.sequence.Sequences;
import com.sun.javafx.runtime.Entry;
import java.io.File;
import java.lang.System;
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
        return new File(home, ".WidgetFX/widgets/{id}.config");
    }
    
    public function load() {
        if (widget.onStart != null) widget.onStart();
        if (widget.configuration != null) {
            var persister = ConfigPersister {configuration: widget.configuration, file: getPropertyFile()}
            persister.load();
        }
    }
    
    public function save() {
        if (widget.configuration != null) {
            var persister = ConfigPersister {configuration: widget.configuration, file: getPropertyFile()}
            persister.save();
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
