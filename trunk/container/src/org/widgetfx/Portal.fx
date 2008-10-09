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
var width:Integer = 500;
var height:Integer = 500;
var frame:Frame = Frame {
    closeAction: function() {java.lang.System.exit(0)}
    width: bind width with inverse
    height: bind height with inverse
    stage: Stage {
        content: WidgetContainer {
            window: bind frame
            widgets: bind WidgetManager.getInstance().widgets[w|w.docked];
            width: bind width
            height: bind height
            layout: GapGridBox {rows: 2, columns: 2, spacing: 5}
        }
    }
    visible: true
}
