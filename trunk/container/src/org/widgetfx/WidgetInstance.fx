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
package org.widgetfx;

import com.sun.javafx.runtime.sequence.Sequence;
import com.sun.javafx.runtime.Entry;
import java.io.File;
import java.lang.*;
import java.net.URL;
import java.util.Arrays;
import javafx.scene.image.*;
import javafx.stage.*;
import javax.jnlp.*;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.xpath.*;
import org.w3c.dom.Attr;
import org.w3c.dom.NodeList;
import org.widgetfx.config.*;
import org.widgetfx.widgets.*;
import org.widgetfx.ui.*;
import org.jfxtras.stage.*;
import java.util.Properties;
import java.io.StringWriter;
import java.net.URLClassLoader;
import org.widgetfx.classloader.WidgetFXClassLoader;

import javafx.io.http.HttpRequest;
import java.io.InputStreamReader;

import java.io.InputStream;

import java.io.StringBufferInputStream;

import java.io.BufferedReader;

/**
 * @author Stephen Chin
 * @author Keith Combs
 */
public var MIN_WIDTH = 100;
public var MIN_HEIGHT = 50;

var JARS_TO_SKIP = ["widgetfx-api", "jfxtras", "swing-worker"];
    
var loadedResources:URL[] = [];

public class WidgetInstance {

    public-init var id:Integer;

    public-init var widgetProperties:java.util.Properties;

    public-init var onLoad:function(instance:WidgetInstance):Void;

    public-read var initialized = false;

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

    var classLoader:URLClassLoader;

    public-init var jnlpUrl:String on replace {
        if (jnlpUrl.length() == 0) {
            mainClass = "";
        } else if (jnlpUrl.toLowerCase().endsWith(".swf") or jnlpUrl.toLowerCase().endsWith(".swfi")) {
            widget = FlashWidget {
                url: resolve(jnlpUrl)
            }
        } else {
            HttpRequest {
                location: resolve(jnlpUrl)
                onInput: parseJNLP
            }.start();
        }
    }

    function parseJNLP(is:InputStream) {
        try {
            var builder = DocumentBuilderFactory.newInstance().newDocumentBuilder();
            var reader = new BufferedReader(new InputStreamReader(is));
            var line;
            var sb = new StringBuilder();
            while ((line = reader.readLine()) != null) {
                if (line.contains("<update check=\"background\">")) {
                    sb.append("<update />");
                } else {
                    sb.append(line);
                }
                sb.append('\n');
            }
            var document = builder.parse(new StringBufferInputStream(sb.toString()));
            var xpath = XPathFactory.newInstance().newXPath();
            var codeBaseString = xpath.evaluate("/jnlp/@codebase", document, XPathConstants.STRING) as String;
            if (not codeBaseString.endsWith("/")) {
                codeBaseString += '/';
            }
            var codeBase = new URL(codeBaseString);
            var widgetNodes = xpath.evaluate("/jnlp/resources/jar", document, XPathConstants.NODESET) as NodeList;
            var ds = ServiceManager.lookup("javax.jnlp.DownloadService") as DownloadService;
            var urlList:URL[];
            for (i in [0..widgetNodes.getLength()-1]) {
                var jarUrl = (widgetNodes.item(i).getAttributes().getNamedItem("href") as Attr).getValue();
                var version = (widgetNodes.item(i).getAttributes().getNamedItem("version") as Attr).getValue();
                if (JARS_TO_SKIP[j|jarUrl.toLowerCase().contains(j.toLowerCase())].isEmpty()) {
                    var url = new URL(codeBase, jarUrl);
                    if (javafx.util.Sequences.indexOf(loadedResources, url) == -1) {
                        // todo - does this unloading work anymore?
                        // todo - does version numbering work? - this is probably just url swizzling and cache magic
                        if (version == null) {
                            WidgetManager.getInstance().maybeUnload(url);
                        }
                        insert url into urlList;
//                            ds.loadResource(url, version, DownloadServiceListener {
//                                override function downloadFailed(url, version) {
//                                    println("download failed");
//                                }
//                                override function progress(url, version, readSoFar, total, overallPercent) {
//                                }
//                                override function upgradingArchive(url, version, patchPercent, overallPercent) {
//                                    println("upgradingArchive");
//                                }
//                                override function validating(url, version, entry, total, overallPercent) {
//                                }
//                            });
                        insert url into loadedResources;
                    }
                }
            }
            classLoader = new WidgetFXClassLoader(urlList, getClass().getClassLoader(), WidgetSecurityDialogFactoryImpl{});
            var arguments = xpath.evaluate("/jnlp/application-desc/argument", document, XPathConstants.NODESET) as NodeList;
            for (i in [0..arguments.getLength() -1]) {
                var argument = xpath.evaluate(".", arguments.item(i), XPathConstants.STRING) as String;
                var index = argument.indexOf("=");
                var name = argument.substring(0, index);
                if (name == "MainJavaFXScript") {
                    mainClass = argument.substring(index + 1);
                }
            }

            if (mainClass.length() == 0) {
                throw new IllegalStateException("No main class specified");
            }
            title = xpath.evaluate("/jnlp/information/title", document, XPathConstants.STRING) as String;
        } catch (e:Throwable) {
            createError(e);
        }
    }

    
    public-init var mainClass:String on replace {
        if (mainClass.length() > 0) {
            try {
                var name = Entry.entryMethodName();
                var widgetClass:Class = Class.forName(mainClass, true, classLoader);
                var emptySeq:Sequence = [];
                widget = widgetClass.getMethod(name, Sequence.<<class>>).invoke(null, emptySeq as Object) as Widget;
            } catch (e:Throwable) {
                createError(e);
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
            dockedWidth = undockedWidth = widget.width;
            dockedHeight = undockedHeight = widget.height;
            initializeDimensions();
            validateConfig();
            if (widget.configuration.onLoad != null) {
                try {
                    widget.configuration.onLoad();
                } catch (e:Throwable) {
                    e.printStackTrace();
                }
            }
            onLoad(this);
            persister.save(); // initial save for loaded widget
            initialized = true;
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
            } else {
                dockedWidth = widget.width;
                dockedHeight = widget.height;
            }
        } else {
            if (widget.resizable) {
                setWidth(undockedWidth);
                setHeight(undockedHeight);
            } else {
                dockedWidth = widget.width;
                dockedHeight = widget.height;
            }
            frame = WidgetFrame {
                instance: this
                x: undockedX, y: undockedY
                style: if (WidgetFXConfiguration.TRANSPARENT and not (widget instanceof FlashWidget)) StageStyle.TRANSPARENT else StageStyle.UNDECORATED
            }
        }
    }

    function validateConfig() {
        if (widget.width < MIN_WIDTH) {
            setWidth(MIN_WIDTH);
        }
        if (widget.height < MIN_HEIGHT) {
            setHeight(MIN_HEIGHT);
        }
        if (opacity < 10 or opacity > 100) {
            opacity = 100;
        }
    }
    
    public function dock() {
        if (not docked) {
            frame.close();
            frame = null;
            docked = true;
            if (widget.onDock != null) {
                widget.onDock();
            }
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

    init {
        if (widgetProperties != null) {
            persister.load(widgetProperties);
        } else {
            persister.load();
        }

        if (jnlpUrl.isEmpty()) {
            createError(new java.lang.IllegalStateException("Widget URL is empty"));
        }
    }
    
    var configDialog:JFXDialog;
    
    public function save() {
        if (widget.configuration.onSave != null) {
            try {
                widget.configuration.onSave();
            } catch (e:Throwable) {
                e.printStackTrace();
            }
        }
        persister.save();
        configDialog.close();
    }

    public function getPropertyString(forceDocked:Boolean):String {
        var properties = new Properties();
        persister.save(properties);
        if (forceDocked) {
            properties.put("widget.docked", "true");
        }
        var stringWriter = new StringWriter();
        properties.store(stringWriter, null);
        return stringWriter.toString();
    }
    
    public function showConfigDialog():Void {
        if (widget instanceof FlashWidget) {
            (widget as FlashWidget).configure();
        } else if (widget.configuration != null) {
            configDialog = JFXDialog {
                icons: Image {
                    url: "{__DIR__}ui/images/WidgetFXIcon16.png"
                }
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
