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

import org.widgetfx.ui.*;
import javafx.lang.FX;
import javafx.scene.*;
import javafx.scene.shape.*;
import javafx.scene.paint.*;
import javafx.stage.*;

/**
 * @author Stephen Chin
 */
WidgetManager.createPortalInstance();
WidgetFXConfiguration.getInstance().mergeProperties = true;
WidgetFXConfiguration.getInstance().load();
Stage {
    onClose: function() {FX.exit()}
    x: 100
    y: 200
    title: "Portal 1"
    var scene:Scene = Scene {
        width: 500
        height: 500
        fill: Color.SLATEGRAY
        content: WidgetContainer {
            widgets: WidgetManager.getInstance().widgets[w|w.docked];
            width: bind scene.width
            height: bind scene.height
            layout: GapGridBox {rows: 2, columns: 3, spacing: 5}
        }
    }
    scene: scene
    visible: true
}

Stage {
    onClose: function() {FX.exit()}
    x: 700
    y: 200
    title: "Portal 2"
    var scene:Scene = Scene {
        width: 200
        height: 500
        var widgetList:WidgetInstance[];
        fill: Color.SLATEGRAY
        content: WidgetContainer {
            widgets: widgetList
            width: bind scene.width
            height: bind scene.height
            layout: GapGridBox {rows: 4, columns: 1, spacing: 5}
        }
    }
    scene: scene
    visible: true
}
