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
package org.widgetfx.ui;

import javafx.application.Dialog;
import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;

/**
 * A special extension of Dialog that hides the taskbar icons while retaining
 * individual window z-order placement.
 *
 * This class uses a modified version of the hidden parent trick used in Swing
 * for the default container, while also taking advantage of the unique property
 * that JDialogs can be focused without a visible parent.
 *
 * @author Stephen Chin
 */
public class BaseDialog extends Dialog {
        
    function createWindow(): java.awt.Window {
        owner = new javafx.application.Frame();
        var window = super.createWindow();
        var listener:WindowAdapter = WindowAdapter {
            public function windowClosed(e:WindowEvent):Void {
                window.removeWindowListener(listener);
                owner.window.dispose();
            }
        };
        window.addWindowListener(listener);
        return window;
    }
}
