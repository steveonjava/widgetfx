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

import javax.jnlp.*;
import org.w3c.dom.Attr;
import org.w3c.dom.NodeList;
import org.widgetfx.config.Configuration;
import java.net.URL;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.xpath.XPathFactory;
import javax.xml.xpath.XPathConstants;
import javafx.lang.Sequences;

/**
 * @author Stephen Chin
 * @author kcombs
 */
public class WidgetManager {
    
    private static attribute JARS_TO_SKIP = ["widgetfx-api.jar", "widgetfx.jar",
        "Scenario.jar", "gluegen-rt.jar", "javafx-swing.jar", "javafxc.jar",
        "javafxdoc.jar", "javafxgui.jar", "javafxrt.jar", "jmc.jar", "jogl.jar"];
    
    private static attribute instance = WidgetManager {}
    
    public static function getInstance() {
        return instance;
    }
    
    public attribute widgets:WidgetInstance[] = [];
    
    private attribute loadedResources:URL[] = [];
    
    private attribute configuration = WidgetFXConfiguration.getInstance();
    
    private attribute idCount = 0;
    
    init {
        // todo - implement a widget security policy
        java.lang.System.setSecurityManager(null);
    }
    
    public function addWidget(jnlpUrl:String, sidebar:Sidebar):WidgetInstance {
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
                    if (Sequences.indexOf(loadedResources, url) == -1) {
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
            var mainClass = xpath.evaluate("/jnlp/application-desc/@main-class", document, XPathConstants.STRING) as String;
            var instance = WidgetInstance{sidebar: sidebar, mainClass: mainClass, id: idCount++};
            if (instance != null) {
                insert instance into widgets;
                instance.load();
            }
            return instance
        } catch (e) {
            java.lang.System.out.println("Unable to load widget at location: {jnlpUrl}");
            e.printStackTrace();
            return null;
        }
    }
    
    public function addWidget(jarPaths:String[], mainClass:String):WidgetInstance {
        var bs = ServiceManager.lookup("javax.jnlp.BasicService") as BasicService;
        var ds = ServiceManager.lookup("javax.jnlp.DownloadService") as DownloadService;
        for (path in jarPaths) {
            var url = new URL(bs.getCodeBase(), path); 
            // reload the resource into the cache 
            var dsl = ds.getDefaultProgressWindow(); 
            ds.loadResource(url, null, dsl);
        }
        var instance = WidgetInstance{mainClass: mainClass, id: 1};
        insert instance into widgets;
        instance.load();
        return instance;
    }
    
    public function getWidgetInstance(widget:Widget):WidgetInstance {
        var match = widgets[w|w.widget == widget];
        return match[0];
    }
    
    public function showConfigDialog(widget:Widget):Void {
        getWidgetInstance(widget).showConfigDialog();
    }

}
