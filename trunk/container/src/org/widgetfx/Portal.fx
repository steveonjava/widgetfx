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
import javafx.application.*;
import javafx.scene.geometry.*;
import javafx.scene.paint.*;

/**
 * @author Stephen Chin
 */
WidgetManager.createPortalInstance();
WidgetFXConfiguration.getInstance().mergeProperties = true;
WidgetFXConfiguration.getInstance().load();
Frame {
    closeAction: function() {java.lang.System.exit(0)}
    x: 100
    y: 200
    width: 500
    height: 500
    title: "Portal 1"
    stage: Stage {
        var width:Integer;
        var height:Integer;
        fill: Color.SLATEGRAY
        width: bind width with inverse
        height: bind height with inverse
        content: WidgetContainer {
            widgets: WidgetManager.getInstance().widgets[w|w.docked];
            width: bind width
            height: bind height
            layout: GapGridBox {rows: 2, columns: 2, spacing: 5}
        }
    }
    visible: true
}

Frame {
    closeAction: function() {java.lang.System.exit(0)}
    x: 700
    y: 200
    width: 500
    height: 500
    title: "Portal 2"
    stage: Stage {
        var widgetList:WidgetInstance[];
        var width:Integer;
        var height:Integer;
        fill: Color.SLATEGRAY
        width: bind width with inverse
        height: bind height with inverse
        content: WidgetContainer {
            widgets: widgetList
            width: bind width
            height: bind height
            layout: GapGridBox {rows: 2, columns: 2, spacing: 5}
        }
    }
    visible: true
}
