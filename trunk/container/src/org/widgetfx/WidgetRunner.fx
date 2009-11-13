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

import javafx.lang.*;
import javafx.scene.Scene;
import javafx.scene.image.Image;
import javafx.scene.image.ImageView;
import javafx.stage.StageStyle;
import org.jfxtras.stage.XDialog;
import org.widgetfx.config.*;
import org.widgetfx.ui.AddWidgetDialog;

/**
 * @author Stephen Chin
 * @author Keith Combs
 */
var instance:WidgetInstance;

var splashScreen = XDialog {
    x: 0
    y: 0
    title: "Widget Runner"
    style: StageStyle.TRANSPARENT
    alwaysOnTop: true
    scene: Scene {
        content: ImageView {
            image: Image {
                url: "http://widgetfx.googlecode.com/svn/site/images/WidgetFX_Logo_Transparent.png"
            }
            onMousePressed: function(e) {
                instance.frame.toFront();
            }
        }
        fill: null
    }
}

for (arg in FX.getArguments() where arg.equals("no-transparency")) {
    WidgetFXConfiguration.TRANSPARENT = false;
}

var widgetCount = 0;

function closeHook() {
    widgetCount--;
    if (widgetCount == 0) {
        FX.exit();
    }
}

function runWidget(jnlpUrl:String) {
    instance = WidgetInstance {
        jnlpUrl: jnlpUrl
        docked: false
        onLoad: function(instance:WidgetInstance) {
            instance.frame.onClose = closeHook;
        }
    };
    WidgetManager.getInstance().addRecentWidget(instance);
    widgetCount++;
}

WidgetManager.createWidgetRunnerInstance();
WidgetFXConfiguration.getInstance().mergeProperties = true;
WidgetFXConfiguration.getInstance().load();

for (arg in FX.getArguments() where arg.toLowerCase().endsWith(".jnlp")) {
    runWidget(arg);
}

if (widgetCount == 0) {
    AddWidgetDialog {
        addHandler: function(jnlpFile:String) {
            runWidget(jnlpFile);
        }
        cancelHandler: function() {
            FX.exit();
        }
    }
}
