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

import javafx.stage.*;
import javafx.scene.layout.*;
import java.awt.Window;
import java.lang.Math;

/**
 * @author Stephen Chin
 * @author Keith Combs
 */
public class Dialog extends Stage {
    public-init var owner:Stage;
    
    public-init var independentFocus = false;
    
    public-init var packed = false;
    
    var delegate:DialogStageDelegate;
    
    public var dialog = bind delegate.dialog;
    
    public function getWindow():Window {
        return WindowHelper.extractWindow(this);
    }
    
    public function pack():Void {
        var preferredWidth:Number = 0;
        var preferredHeight:Number = 0;
        for (node in scene.content) {
            if (node instanceof Resizable) {
                var resizable = node as Resizable;
                preferredWidth = Math.max(preferredWidth, resizable.preferredWidth);
                preferredHeight = Math.max(preferredHeight, resizable.preferredHeight);
            } else {
                preferredWidth = Math.max(preferredWidth, node.boundsInLocal.width);
                preferredHeight = Math.max(preferredHeight, node.boundsInLocal.height);
            }
        }
        width = preferredWidth + width - scene.width;
        height = preferredHeight + height - scene.height;
        dialog.setLocationRelativeTo(null);
    }
    
    init {
        if (packed) {
            visible = false;
        }
        DialogStageDelegate.owner = owner;
        DialogStageDelegate.independentFocus = independentFocus;
        DialogStageDelegate.style = style;
        impl_stageDelegate = delegate = DialogStageDelegate {
            stage: this
            dialogTitle: bind title
            dialogResizable: bind resizable
        }
    }
    
    postinit {
        if (packed) {
            FX.deferAction(
                function():Void {
                    pack();
                    visible = true;
                }
            );
        }
    }
}
