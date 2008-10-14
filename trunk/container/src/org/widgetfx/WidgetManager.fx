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

import java.lang.System;
import java.util.Arrays;
import java.net.URL;
import javafx.lang.*;
import javafx.util.*;
import javax.jnlp.*;
import org.widgetfx.config.IntegerSequenceProperty;
import org.widgetfx.config.StringSequenceProperty;
import org.widgetfx.ui.ErrorWidget;

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
        "../../widgets/Clock/dist/launch.jnlp",
        "../../widgets/SlideShow/dist/launch.jnlp",
        "../../widgets/WebFeed/dist/launch.jnlp"
    ] else [
        "{codebase}widgets/Clock/launch.jnlp",
        "{codebase}widgets/SlideShow/launch.jnlp",
        "{codebase}widgets/WebFeed/launch.jnlp"
    ];
    
    public-read var recentWidgets:String[] = [];
    
    var configuration = WidgetFXConfiguration.getInstanceWithProperties([
        IntegerSequenceProperty {
            name: "widgets"
            value: bind widgetIds with inverse
        },
        StringSequenceProperty {
            name: "recentWidgets"
            value: bind recentWidgets with inverse
        }
    ]);

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
        for (param in params where param.toLowerCase().endsWith(".jnlp")) {
            addWidget(param);
        }
        for (param in params where param.toLowerCase().endsWith(".theme")) {
            Dock.getInstance().theme = param;
        }
    }
    
    var sis = ServiceManager.lookup("javax.jnlp.SingleInstanceService") as SingleInstanceService;
    var sil = SingleInstanceListener {
        override function newActivation(params) {
            FX.deferAction(
                function():Void {
                    Dock.getInstance().showDockAndWidgets();
                    loadParams(for (s in Arrays.asList(params)) s);
                }
            );
        }
    };

    init {
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
        instance.load();
        return instance;
    }
    
    public function removeWidget(instance:WidgetInstance):Void {
        instance.deleteConfig();
        delete instance from widgets;
    }
    
    public function addWidget(jnlpUrl:String):WidgetInstance {
        for (widget in widgets) {
            if (widget.jnlpUrl.equals(jnlpUrl)) {
                System.out.println("Widget already loaded: {jnlpUrl}");
                return null;
            }
        }
        var maxId = if (widgetIds.isEmpty()) 0 else (Sequences.max(widgetIds) as Integer).intValue();
        var instance = WidgetInstance{jnlpUrl: jnlpUrl, id: maxId + 1};
        insert instance into widgets;
        instance.load();
        addRecentWidget(instance);
        return instance
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
