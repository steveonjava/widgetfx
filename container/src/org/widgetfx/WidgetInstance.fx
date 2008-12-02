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

import org.w3c.dom.Attr;
import org.w3c.dom.NodeList;
import org.widgetfx.config.*;
import org.widgetfx.ui.ErrorWidget;
import org.widgetfx.ui.FlashWidget;
import org.jfxtras.stage.*;
import com.sun.javafx.runtime.TypeInfo;
import com.sun.javafx.runtime.sequence.Sequence;
import com.sun.javafx.runtime.sequence.Sequences;
import com.sun.javafx.runtime.Entry;
import java.awt.GraphicsEnvironment;
import java.io.File;
import java.lang.*;
import java.net.URL;
import java.util.Arrays;
import javafx.ext.swing.*;
import javafx.reflect.*;
import javafx.scene.*;
import javafx.stage.*;
import javax.jnlp.*;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.xpath.*;

/**
 * @author Stephen Chin
 * @author Keith Combs
 */
public var MIN_WIDTH = 100;
public var MIN_HEIGHT = 50;

var JARS_TO_SKIP = ["widgetfx-api.jar", "widgetfx.jar", "jfxtras.jar",
        "Scenario.jar", "gluegen-rt.jar", "javafx-swing.jar", "javafxc.jar",
        "javafxdoc.jar", "javafxgui.jar", "javafxrt.jar", "jmc.jar", "jogl.jar"];
    
var loadedResources:URL[] = [];

public class WidgetInstance {

    public-init var id:Integer;

    bound function getPropertyFile():File {
        var filename = if (id == 0) jnlpUrl.replaceAll("[^a-zA-Z0-9]", "_") else id;
        return new File(WidgetFXConfiguration.getInstance().configFolder, "widgets/{filename}.config");
    }
    
    // todo - possibly prevent widgets from loading if they define user properties that start with "widget."
    var properties = [
        StringProperty {
            name: "widget.jnlpUrl"
            value: bind jnlpUrl with inverse
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
        NumberProperty {
            name: "widget.dockedWidth"
            value: bind dockedWidth with inverse
        },
        NumberProperty {
            name: "widget.dockedHeight"
            value: bind dockedHeight with inverse
        },
        NumberProperty {
            name: "widget.undockedX"
            value: bind undockedX with inverse
        },
        NumberProperty {
            name: "widget.undockedY"
            value: bind undockedY with inverse
        },
        NumberProperty {
            name: "widget.undockedWidth"
            value: bind undockedWidth with inverse;
        },
        NumberProperty {
            name: "widget.undockedHeight"
            value: bind undockedHeight with inverse;
        }
    ];
    
    var persister = bind ConfigPersister {properties: bind [properties, widget.configuration.properties], file: getPropertyFile()}
    
    function resolve(url:String):String {
        return (new URL(WidgetManager.getInstance().codebase, url)).toString();
    }

    public-init var jnlpUrl:String on replace {
        if (jnlpUrl.length() == 0) {
            mainClass = "";
        } else if (jnlpUrl.toLowerCase().endsWith(".swf") or jnlpUrl.toLowerCase().endsWith(".swfi")) {
            widget = FlashWidget {
                url: jnlpUrl
            }
        } else {
            try {
                var builder = DocumentBuilderFactory.newInstance().newDocumentBuilder();
                var document = builder.parse(resolve(jnlpUrl));
                var xpath = XPathFactory.newInstance().newXPath();
                var codeBaseString = xpath.evaluate("/jnlp/@codebase", document, XPathConstants.STRING) as String;
                if (not codeBaseString.endsWith("/")) {
                    codeBaseString += '/';
                }
                var codeBase = new URL(codeBaseString);
                var widgetNodes = xpath.evaluate("/jnlp/resources/jar", document, XPathConstants.NODESET) as NodeList;
                var ds = ServiceManager.lookup("javax.jnlp.DownloadService") as DownloadService;
                for (i in [0..widgetNodes.getLength()-1]) {
                    var jarUrl = (widgetNodes.item(i).getAttributes().getNamedItem("href") as Attr).getValue();
                    if (JARS_TO_SKIP[j|jarUrl.toLowerCase().contains(j.toLowerCase())].isEmpty()) {
                        var url = new URL(codeBase, jarUrl);
                        if (javafx.util.Sequences.indexOf(loadedResources, url) == -1) {
                            ds.loadResource(url, null, DownloadServiceListener {
                                override function downloadFailed(url, version) {
                                    println("download failed");
                                }
                                override function progress(url, version, readSoFar, total, overallPercent) {
                                }
                                override function upgradingArchive(url, version, patchPercent, overallPercent) {
                                    println("upgradingArchive");
                                }
                                override function validating(url, version, entry, total, overallPercent) {
                                }
                            });
                            insert url into loadedResources;
                        }
                    }
                }
                mainClass = xpath.evaluate("/jnlp/application-desc/@main-class", document, XPathConstants.STRING) as String;
                if (mainClass.length() == 0) {
                    throw new IllegalStateException("No main class specified");
                }
                title = xpath.evaluate("/jnlp/information/title", document, XPathConstants.STRING) as String;
            } catch (e:Throwable) {
                createError(e);
            }
        }
    }
    
    public-init var mainClass:String on replace {
        if (mainClass.length() > 0) {
            try {
                var widgetClass:Class = Class.forName(mainClass);
                var name = Entry.entryMethodName();
                widget = widgetClass.getMethod(name, Sequence.<<class>>).invoke(null, TypeInfo.String.emptySequence as Object) as Widget;
            } catch (e:Throwable) {
                createError(e);
            } finally {
                if (widget != null) {
                    widget.autoLaunch = false;
                }
            }
        }
    }
    
    function createError(e:Throwable) {
        if (title == null) {
            title = "Error";
        }
        widget = ErrorWidget {
            errorLines: [
                "Unable to load widget:",
                jnlpUrl,
                e.getMessage()
            ]
        }
        e.printStackTrace();
    }

    public var opacity:Integer = 80;
    public var docked:Boolean = true;
    public var dockedWidth:Number;
    public var dockedHeight:Number;
    public var undockedX:Number;
    public var undockedY:Number;
    public var undockedWidth:Number;
    public var undockedHeight:Number;
    
    public function setWidth(width:Number) {
        widget.width = width;
    }
    
    public function setHeight(height:Number) {
        widget.height = height;
    }
    
    public-init var widget:Widget on replace {
        if (widget != null) {
            if (widget.width < MIN_WIDTH) {
                setWidth(MIN_WIDTH);
            }
            if (widget.height < MIN_HEIGHT) {
                setHeight(MIN_HEIGHT);
            }
            undockedWidth = widget.width;
            undockedHeight = widget.height;
        }
    }
    public var title:String;
    public var frame:WidgetFrame;
    
    public var stageWidth = bind widget.width on replace {
        if (widget.width > 0) {
            if (docked) {
                dockedWidth = widget.width;
            } else {
                undockedWidth = widget.width;
            }
        }
    }
    
    public var stageHeight = bind widget.height on replace {
        if (widget.height > 0) {
            if (docked) {
                dockedHeight = widget.height;
            } else {
                undockedHeight = widget.height;
            }
        }
    }
    
    public function saveWithoutNotification() {
        persister.save();
    }

    function initializeDimensions() {
        if (docked) {
            if (widget.resizable) {
                setWidth(dockedWidth);
                setHeight(dockedHeight);
            }
        } else {
            if (widget.resizable) {
                setWidth(undockedWidth);
                setHeight(undockedHeight);
            }
            frame = WidgetFrame {
                instance: this
                x: undockedX, y: undockedY
                style: if (WidgetFXConfiguration.TRANSPARENT and not (widget instanceof FlashWidget)) StageStyle.TRANSPARENT else StageStyle.UNDECORATED
            }
        }
    }
    
    public function dock() {
        frame.close();
        frame = null;
        docked = true;
        if (widget.onDock != null) {
            widget.onDock();
        }
    }
    
    public function dockIfOffscreen() {
        if (not docked) {
            var found = false;
            for (gd in Arrays.asList(java.awt.GraphicsEnvironment.getLocalGraphicsEnvironment().getScreenDevices())) {
                var gc = gd.getDefaultConfiguration();
                if (gc.getBounds().intersects(new java.awt.Rectangle(undockedX, undockedY, undockedWidth, undockedHeight))) {
                    found = true;
                }
            }
            if (not found) {
                dock();
            }
        }
    }
    
    public function load() {
        if (not persister.load()) {
            persister.save(); // initial save
        }
        initializeDimensions();
        if (widget.configuration.onLoad != null) {
            try {
                widget.configuration.onLoad();
            } catch (e:Throwable) {
                e.printStackTrace();
            }
        }
    }
    
    var configDialog:Dialog;
    
    public function save() {
        persister.save();
        if (widget.configuration.onSave != null) {
            try {
                widget.configuration.onSave();
            } catch (e:Throwable) {
                e.printStackTrace();
            }
        }
        configDialog.close();
    }
    
	// todo:merge - this needs to be commented out temporarily
    public function showConfigDialog():Void {
        if (widget instanceof FlashWidget) {
            (widget as FlashWidget).configure();
        } else if (widget.configuration != null) {
            configDialog = Dialog {
                icons: WidgetFXConfiguration.getInstance().widgetFXIcon16s
                title: "{title} Configuration"
                resizable: false
                onClose: save
                scene: widget.configuration.scene
            }
        }
    }

    package function deleteConfig() {
        getPropertyFile().<<delete>>();
    }
}
