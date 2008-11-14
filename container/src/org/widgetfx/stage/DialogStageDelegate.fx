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
package org.widgetfx.stage;

import com.sun.javafx.stage.*;
import javafx.stage.*;
import java.awt.Dimension;
import java.awt.Frame;
import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;
import javax.swing.JDialog;

/**
 * @author Stephen Chin
 * @author Keith Combs
 */

// These variables are public to allow initialization before the base class.
// Set them before calling the constructor to take effect.
public var owner:Stage;
public var independentFocus:Boolean;
public var style:StageStyle;

public class DialogStageDelegate extends WindowStageDelegate {
    public var dialog:JDialog;
    
    // can't use the superclass title attribute, because it has package only access
    public var dialogTitle:String on replace {
        dialog.setTitle(dialogTitle);
    }
    
    // can't use the superclass resizable attribute, because it has package only access
    public var dialogResizable:Boolean on replace {
        dialog.setResizable(dialogResizable);
    }
    
    override function close() {
        stage.visible = false;
        dialog.dispose();
    }
    
    override function createWindow(): java.awt.Window {
        var ownerWindow = if (independentFocus) new Frame()
            else if (owner == null) null
            else WindowHelper.extractWindow(owner);
        dialog = WindowHelper.createJDialog(ownerWindow);
        if (independentFocus) {
            var listener:WindowAdapter = WindowAdapter {
                override function windowClosed(e:WindowEvent):Void {
                    dialog.removeWindowListener(listener);
                    ownerWindow.dispose();
                }
            };
            dialog.addWindowListener(listener);
        }
        if (style == StageStyle.TRANSPARENT) {
            dialog.setUndecorated(true);
            dialog.setSize(new Dimension(1, 1));
            WindowImpl.setWindowTransparency(dialog, true);
        } else if (style == StageStyle.UNDECORATED) {
            dialog.setUndecorated(true);
        }
        owner = null;
        independentFocus = false;
        style = null;
        return dialog;
    }
}
