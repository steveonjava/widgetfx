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

import java.lang.Long;
import java.lang.System;
import java.util.Arrays;
import java.net.HttpURLConnection;
import java.net.URL;
import javafx.lang.*;
import javafx.util.*;
import javax.jnlp.*;
import org.widgetfx.communication.*;
import org.widgetfx.config.*;
import org.widgetfx.widgets.*;
import org.widgetfx.ui.*;
import java.util.Properties;

/**
 * @author Stephen Chin
 * @author Keith Combs
 */
var instance:WidgetManager;
    
public function createWidgetRunnerInstance() {
    instance = WidgetManager {widgetRunner: true};
}

public function createPortalInstance() {
    instance = WidgetManager {portal: true};
}

public function getInstance() {
    if (instance == null) {
        instance = WidgetManager {};
    }
    return instance;
}
    
public class WidgetManager {
    
    public var widgetRunner = false;
    
    public var portal = false;
    
    public-read var codebase = WidgetFXConfiguration.getInstance().codebase;
    
    var initialWidgets = if (WidgetFXConfiguration.getInstance().devMode) [
        "../../widgets/Clock/dist/Clock.jnlp",
        "../../widgets/SlideShow/dist/SlideShow.jnlp",
        "../../widgets/WebFeed/dist/WebFeed.jnlp"
    ] else [
        "{codebase}widgets/Clock/launch.jnlp",
        "{codebase}widgets/SlideShow/launch.jnlp",
        "{codebase}widgets/WebFeed/launch.jnlp"
    ];
    
    public-read var recentWidgets:String[] = [];
    
    var loginTokens:String[] = [];
    
    var loginUsernames:String[] = [];
    
    var loginPasswords:String[] = [];

    public var stylesheets:String[] = [];

    var resourceUrls:String[];

    var resourceTimestamps:Long[];

    var configuration = WidgetFXConfiguration.getInstanceWithProperties([
        StringSequenceProperty {
            name: "resourceUrls"
            value: bind resourceUrls with inverse;
        },
        LongSequenceProperty {
            name: "resourceTimestamps"
            value: bind resourceTimestamps with inverse;
        },
        IntegerSequenceProperty {
            name: "widgets"
            value: bind widgetIds with inverse
        },
        StringSequenceProperty {
            name: "recentWidgets"
            value: bind recentWidgets with inverse
        },
        StringSequenceProperty {
            name: "loginTokens"
            value: bind loginTokens with inverse
        },
        StringSequenceProperty {
            name: "loginUsernames"
            value: bind loginUsernames with inverse
        },
        StringSequenceProperty {
            name: "loginPasswords"
            value: bind loginPasswords with inverse
        },
        StringSequenceProperty {
            name: "styles"
            value: bind stylesheets with inverse;
        }
    ]);

    public function maybeUnload(url:URL):Void {
        var ds = ServiceManager.lookup("javax.jnlp.DownloadService") as DownloadService;
        if (ds.isResourceCached(url, null)) {
            if (urlUpdated(url)) {
                println("Resource updated: {url}");
                ds.removeResource(url, null);
            }
        }
    }

    function urlUpdated(url:URL):Boolean {
        var conn = url.openConnection();
        if (conn instanceof HttpURLConnection) try {
            var httpConn = conn as HttpURLConnection;
            httpConn.setConnectTimeout(3000);
            httpConn.setRequestMethod("HEAD");
            var time:Long = conn.getLastModified();
            httpConn.disconnect();
            var urlInd = Sequences.indexOf(resourceUrls, url.toString());
            if (urlInd != -1) {
                if (time.longValue() > resourceTimestamps[urlInd]) {
                    resourceTimestamps[urlInd] = time;
                    return true;
                }
            } else {
                insert url.toString() into resourceUrls;
                insert time into resourceTimestamps;
                return true;
            }
        } catch (e:java.net.SocketTimeoutException) {
            println("Timed out connecting to server: {url}");
        }
        return false;
    }

    public function lookupCredentials(token:String):String[] {
        var index = Sequences.indexOf(loginTokens, token);
        if (index == -1) {
            return null;
        }
        return [loginUsernames[index], loginPasswords[index]];
    }
    
    public function storeCredentials(token:String, username:String, password:String) {
        var index = Sequences.indexOf(loginTokens, token);
        if (index == -1) {
            insert token into loginTokens;
            insert username into loginUsernames;
            insert password into loginPasswords;
        } else {
            loginUsernames[index] = username;
            loginPasswords[index] = password;
        }
    }

    var updating:Boolean;

    var widgetIds:Integer[] on replace [i..j]=newWidgetIds {
        if (not widgetRunner and not updating) {
            try {
                updating = true;
                widgets[i..j] = for (id in newWidgetIds) loadWidget(id);
            } finally {
                updating = false;
            }
        }
    }
    
    public var widgets:WidgetInstance[] = [] on replace [i..j]=newWidgets {
        if (not updating) {
            try {
                updating = true;
                widgetIds[i..j] = for (widget in newWidgets) widget.id;
            } finally {
                updating = false;
            }
        }
    }
    
    public function loadParams(params:String[]) {
        for (param in params where param.toLowerCase().endsWith(".jnlp") or param.toLowerCase().endsWith(".swf") or param.toLowerCase().endsWith(".swfi")) {
            addWidget(param);
        }
        for (param in params where param.toLowerCase().endsWith(".css")) {
            addStylesheet(param);
        }
    }
    
    var sis = ServiceManager.lookup("javax.jnlp.SingleInstanceService") as SingleInstanceService;
    var sil = SingleInstanceListener {
        override function newActivation(params) {
            FX.deferAction(
                function():Void {
                    DockDialog.getInstance().showDockAndWidgets();
                    loadParams(for (s in Arrays.asList(params)) s);
                }
            );
        }
    }

    init {
        Widget.autoLaunch = false;
        CommunicationManager.INSTANCE.startServer();
        CommunicationManager.INSTANCE.setCommandProcessor(WidgetCommandProcessor {});
        if (not widgetRunner and not portal) {
            sis.addSingleInstanceListener(sil);
        }
        // todo - implement a widget security policy
        System.setSecurityManager(null);
    }
    
    public function reload() {
        var basicService = ServiceManager.lookup("javax.jnlp.BasicService") as BasicService;
        sis.removeSingleInstanceListener(sil);
        basicService.showDocument(new URL(basicService.getCodeBase(), "launch.jnlp"));
        FX.exit();
    }
    
    public function exit() {
        if (sis != null) {
            sis.removeSingleInstanceListener(sil);
        }
        FX.exit();
    }
    
    public function dockOffscreenWidgets() {
        for (instance in widgets) {
            instance.dockIfOffscreen();
        }
    }
    
    public function loadInitialWidgets() {
        for (url in initialWidgets) {
            addWidget(url);
        }
    }
    
    function loadWidget(id:Integer):WidgetInstance {
        var instance = WidgetInstance{id: id};
        instance.load(null);
        return instance;
    }
    
    public function removeWidget(instance:WidgetInstance):Void {
        if (not widgetRunner) {
            instance.deleteConfig();
        }
        delete instance from widgets;
    }

    public function hasWidget(url:String, properties:Properties):Boolean {
        if (properties != null) {
            return false;
        }
        for (widget in widgets) {
            if (widget.jnlpUrl.equals(url)) {
                println("Widget already loaded: {url}");
                return true;
            }
        }
        return false;
    }
    
    public function getWidget(url:String):WidgetInstance {
        getWidget(url, null);
    }

    public function getWidget(url:String, properties:Properties):WidgetInstance {
        println("adding widget: {url}");
        if (hasWidget(url, properties)) {
            return null;
        }
        var maxId = if (widgetIds.isEmpty()) 0 else (Sequences.max(widgetIds) as Integer).intValue();
        var instance = WidgetInstance{jnlpUrl: url, id: maxId + 1};
        instance.load(properties);
        addRecentWidget(instance);
        return instance;
    }

    public function addWidget(url:String):WidgetInstance {
        var instance = getWidget(url);
        insert instance into widgets;
        return instance;
    }

    public function clearStylesheets() {
        stylesheets = [];
    }

    public function addStylesheet(url:String) {
        delete url from stylesheets;
        insert url into stylesheets;
    }
    
    public function addRecentWidget(instance:WidgetInstance):Void {
        if (instance.widget instanceof ErrorWidget or
            Sequences.indexOf(recentWidgets, instance.jnlpUrl) != -1) {
            return;
        }
        insert instance.jnlpUrl into recentWidgets;
    }
    
    public function getWidgetInstance(widget:Widget):WidgetInstance {
        var match = widgets[w|w.widget == widget];
        return match[0];
    }

}
