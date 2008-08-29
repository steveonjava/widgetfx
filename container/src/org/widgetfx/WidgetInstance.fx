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
import org.w3c.dom.Attr;
import org.w3c.dom.NodeList;
import org.widgetfx.config.*;
import com.sun.javafx.runtime.sequence.Sequence;
import com.sun.javafx.runtime.sequence.Sequences;
import com.sun.javafx.runtime.Entry;
import java.io.File;
import java.lang.System;
import java.net.URL;
import javafx.application.Dialog;
import javafx.application.Stage;
import javafx.ext.swing.ComponentView;
import javafx.ext.swing.BorderPanel;
import javafx.ext.swing.Button;
import javafx.scene.HorizontalAlignment;
import javafx.ext.swing.FlowPanel;
import javax.jnlp.*;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.xpath.XPathFactory;
import javax.xml.xpath.XPathConstants;

/**
 * @author Stephen Chin
 * @author Keith Combs
 */
public class WidgetInstance {
    private static attribute JARS_TO_SKIP = ["widgetfx-api.jar", "widgetfx.jar",
        "Scenario.jar", "gluegen-rt.jar", "javafx-swing.jar", "javafxc.jar",
        "javafxdoc.jar", "javafxgui.jar", "javafxrt.jar", "jmc.jar", "jogl.jar"];
    
    private static attribute loadedResources:URL[] = [];

    public attribute id:Integer;

    private bound function getPropertyFile():File {
        var home = System.getProperty("user.home");
        return new File(home, ".WidgetFX/widgets/{id}.config");
    }
    
    // todo - possibly prevent widgets from loading if they define user properties that start with "widget."
    private attribute properties = [
        StringProperty {
            name: "widget.jnlpUrl"
            value: bind jnlpUrl with inverse
            autoSave: true
        },
        StringProperty {
            name: "widget.mainClass"
            value: bind mainClass with inverse
            autoSave: true
        },
        IntegerProperty {
            name: "widget.opacity"
            value: bind opacity with inverse
        },
        BooleanProperty {
            name: "widget.docked"
            value: bind docked with inverse
            autoSave: true
        },
        IntegerProperty {
            name: "widget.dockedWidth"
            value: bind dockedWidth with inverse
        },
        IntegerProperty {
            name: "widget.dockedHeight"
            value: bind dockedHeight with inverse
        },
        IntegerProperty {
            name: "widget.undockedX"
            value: bind undockedX with inverse
        },
        IntegerProperty {
            name: "widget.undockedY"
            value: bind undockedY with inverse
        },
        IntegerProperty {
            name: "widget.undockedWidth"
            value: bind undockedWidth with inverse;
        },
        IntegerProperty {
            name: "widget.undockedHeight"
            value: bind undockedHeight with inverse;
        }
    ];
    
    private attribute persister = ConfigPersister {properties: bind [properties, widget.configuration.properties], file: bind getPropertyFile()}
    
    public attribute jnlpUrl:String on replace {
        if (jnlpUrl.length() == 0) {
            mainClass = "";
        } else {
            try {
                var builder = DocumentBuilderFactory.newInstance().newDocumentBuilder();
                var document = builder.parse(jnlpUrl);
                var xpath = XPathFactory.newInstance().newXPath();
                var codeBase = new URL(xpath.evaluate("/jnlp/@codebase", document, XPathConstants.STRING) as String);
                var widgetNodes = xpath.evaluate("/jnlp/resources/jar", document, XPathConstants.NODESET) as NodeList;
                var ds = ServiceManager.lookup("javax.jnlp.DownloadService") as DownloadService;
                for (i in [0..widgetNodes.getLength()-1]) {
                    var jarUrl = (widgetNodes.item(i).getAttributes().getNamedItem("href") as Attr).getValue();
                    if (JARS_TO_SKIP[j|jarUrl.toLowerCase().contains(j.toLowerCase())].isEmpty()) {
                        var url = new URL(codeBase, jarUrl);
                        if (javafx.lang.Sequences.indexOf(loadedResources, url) == -1) {
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
                            insert url into loadedResources;
                        }
                    }
                }
                mainClass = xpath.evaluate("/jnlp/application-desc/@main-class", document, XPathConstants.STRING) as String;
            } catch (e) {
                java.lang.System.out.println("Unable to load widget at location: {jnlpUrl}");
                e.printStackTrace();
            }
        }
    }
    
    public attribute mainClass:String on replace {
        if (mainClass.length() == 0) {
            widget = null;
        } else {
            try {
                var widgetClass:Class = Class.forName(mainClass);
                var name = Entry.entryMethodName();
                var args = Sequences.make(java.lang.String.<<class>>) as java.lang.Object;
                widget = widgetClass.getMethod(name, Sequence.<<class>>).invoke(null, args) as Widget;
            } catch (e:java.lang.RuntimeException) {
                e.printStackTrace();
            }
        }
    }

    public attribute opacity:Integer = 80;
    public attribute docked:Boolean = true;
    public attribute dockedWidth:Integer;
    public attribute dockedHeight:Integer;
    public attribute undockedX:Integer;
    public attribute undockedY:Integer;
    public attribute undockedWidth:Integer;
    public attribute undockedHeight:Integer;
    
    public attribute widget:Widget;
    public attribute frame:WidgetFrame;
    
    private attribute stageWidth = bind widget.stage.width on replace {
        if (widget.stage.width > 0) {
            if (docked) {
                dockedWidth = widget.stage.width;
            } else {
                undockedWidth = widget.stage.width;
            }
        }
    }
    
    private attribute stageHeight = bind widget.stage.height on replace {
        if (widget.stage.height > 0) {
            if (docked) {
                dockedHeight = widget.stage.height;
            } else {
                undockedHeight = widget.stage.height;
            }
        }
    }
    
    function saveWithoutNotification() {
        persister.save();
    }
    
    private function initializeDimensions() {
        if (docked) {
            if (dockedWidth > 0) {
                widget.stage.width = dockedWidth;
            }
            if (dockedHeight > 0) {
                widget.stage.height = dockedHeight;
            }
        } else {
            if (undockedWidth > 0) {
                widget.stage.width = undockedWidth;
            }
            if (undockedHeight > 0) {
                widget.stage.height = undockedHeight;
            }
            frame = WidgetFrame {
                instance: this
                x: undockedX, y: undockedY
            }
        }
    }
    
    public function load() {
        if (not persister.load()) {
            persister.save(); // initial save
        }
        if (widget.onStart != null) widget.onStart();
        initializeDimensions();
        if (widget.configuration.onLoad != null) {
            widget.configuration.onLoad();
        }
    }
    
    public function save() {
        persister.save();
        if (widget.configuration.onSave != null) {
            widget.configuration.onSave();
        }
    }
    
    public function cancel() {
        if (widget.configuration.onCancel != null) {
            widget.configuration.onCancel();
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
