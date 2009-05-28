/*
 * WidgetFX - JavaFX Desktop Widget Platform
 * Copyright (c) 2008-2009, WidgetFX Group
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 1. Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 * 3. Neither the name of WidgetFX nor the names of its contributors may be used
 *    to endorse or promote products derived from this software without
 *    specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */
package org.widgetfx;

import org.widgetfx.config.*;
import org.widgetfx.layout.*;
import org.widgetfx.ui.*;
import org.jfxtras.stage.*;
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
var container:WidgetContainer;
var grid:Stage = Stage {
    onClose: function() {FX.exit()}
    x: 100
    y: 200
    title: "Portal 1"
    width: 500
    height: 500
    var scene:Scene = Scene {
        fill: Color.SLATEGRAY
        content: container = WidgetContainer {
            width: bind scene.width
            height: bind scene.height
            widgets: WidgetManager.getInstance().widgets[w|w.docked];
            gapBox: GapGridBox {rows: 2, columns: 3, spacing: 5}
        }
    }
    scene: scene
}
container.window = WindowHelper.extractWindow(grid);

var list:Stage = Stage {
    onClose: function() {FX.exit()}
    x: 700
    y: 200
    title: "Portal 2"
    width: 200
    height: 500
    var scene:Scene = Scene {
        var widgetList:WidgetInstance[];
        fill: Color.SLATEGRAY
        content: container = WidgetContainer {
            width: bind scene.width
            height: bind scene.height
            widgets: widgetList
            gapBox: GapGridBox {rows: 4, columns: 1, spacing: 5}
        }
    }
    scene: scene
}
container.window = WindowHelper.extractWindow(list);
