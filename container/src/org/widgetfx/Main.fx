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

import javax.swing.UIManager;
import javafx.lang.FX;

/**
 * @author Stephen Chin
 */
java.lang.System.setProperty("apple.awt.UIElement", "true");

try { // try nimbus look and feel first
    UIManager.setLookAndFeel("com.sun.java.swing.plaf.nimbus.NimbusLookAndFeel");
} catch (e) { // fall back on system look and feel
    UIManager.setLookAndFeel(UIManager.getSystemLookAndFeelClassName());
}

for (arg in FX.getArguments()) {
    if (arg.equals("no-transparency")) {
        WidgetFXConfiguration.TRANSPARENT = false;
    }
}

Dock.createInstance();

FX.deferAction(
    function() {
        WidgetManager.getInstance().loadParams(FX.getArguments());
    }
);