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

import javafx.lang.DeferredTask;
import javax.swing.UIManager;
import java.lang.System;

/**
 * @author Stephen Chin
 * @author Keith Combs
 */
try { // try nimbus look and feel first
    UIManager.setLookAndFeel("com.sun.java.swing.plaf.nimbus.NimbusLookAndFeel");
} catch (e) { // fall back on system look and feel
    UIManager.setLookAndFeel(UIManager.getSystemLookAndFeelClassName());
}

for (arg in __ARGS__ where arg.equals("no-transparency")) {
    WidgetFXConfiguration.TRANSPARENT = false;
}

var widgetCount = 0;

function closeHook(frame:WidgetFrame) {
    widgetCount--;
    frame.close();
    if (widgetCount == 0) {
        System.exit(0);
    }
}

for (arg in __ARGS__ where arg.toLowerCase().endsWith(".jnlp")) {
    // todo - fix the id
    var instance = WidgetInstance {
        jnlpUrl: arg
        docked: false
    };
    widgetCount++;
    instance.load();
    instance.frame.onClose = closeHook;
}