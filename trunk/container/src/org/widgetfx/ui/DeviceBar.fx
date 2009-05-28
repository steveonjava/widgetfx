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
package org.widgetfx.ui;

import org.jfxtras.stage.*;
import org.jfxtras.scene.layout.*;
import org.widgetfx.*;
import javafx.ext.swing.*;
import javafx.geometry.*;
import javafx.scene.*;
import javafx.scene.image.*;
import javafx.scene.layout.*;
import javafx.scene.text.*;
import javafx.stage.*;
import javax.swing.JProgressBar;

import javafx.scene.paint.*;
import javafx.scene.shape.*;
import org.widgetfx.ui.WidgetDragListener;
import javafx.animation.*;
import java.util.Properties;

/**
 * @author Stephen Chin
 */
public class DeviceBar extends CustomNode, WidgetDragListener {

    public var owner:Stage;

    function sendTo(device:String) {
        var progressBar = new JProgressBar();
        var dialog = JFXDialog {
            owner: owner
            title: "Device Transfer"
            scene: Scene {
                content: Grid {
                    rows: [
                        Row {cells: Text {content: "Sending to {device}..."}},
                        Row {cells: SwingComponent.wrap(progressBar)}
                    ]
                }
            }
        }
        progressBar.setIndeterminate(true);
        Timeline {
            keyFrames: KeyFrame {
                time: 5s
                action: function() {dialog.close()}
            }
        }.play();
    }
    
    var phoneHover:Boolean;
    var phoneView:ImageView = ImageView {
        image: bind if (phoneHover or phoneView.hover) {
            Image {url: "{__DIR__}images/device_phone_hover.png"}
        } else {
            Image {url: "{__DIR__}images/device_phone.png"}
        }
        onMouseReleased: function(e) {
            sendTo("Phone");
        }
    }

    var laptopHover:Boolean;
    var laptopView:ImageView = ImageView {
        image: bind if (laptopHover or laptopView.hover) {
            Image {url: "{__DIR__}images/device_laptop_hover.png"}
        } else {
            Image {url: "{__DIR__}images/device_laptop.png"}
        }
        onMouseReleased: function(e) {
            sendTo("Laptop");
        }
    }

    var tvHover:Boolean;
    var tvView:ImageView = ImageView {
        image: bind if (tvHover or tvView.hover) {
            Image {url: "{__DIR__}images/device_tv_hover.png"}
        } else {
            Image {url: "{__DIR__}images/device_tv.png"}
        }
        onMouseReleased: function(e) {
            sendTo("TV");
        }
    }

    override function create() {
        return HBox {
            spacing: 10
            content: [
                phoneView,
                laptopView,
                tvView
            ]
        }
    }

    init {
        insert this into WidgetDragListener.dragListeners;
    }

    override function hover(dockedHeight:Number, screenX:Number, screenY:Number):Rectangle2D {
        var sceneX = screenX - scene.stage.x;
        var sceneY = screenY - scene.stage.y;
        phoneHover = phoneView.boundsInScene.contains(sceneX, sceneY);
        laptopHover = laptopView.boundsInScene.contains(sceneX, sceneY);
        tvHover = tvView.boundsInScene.contains(sceneX, sceneY);
        return null;
    }

    override function finishHover(instance:WidgetInstance, screenX:Number, screenY:Number):Rectangle2D {
        if (phoneHover) {
            sendTo("Phone");
        }
        if (laptopHover) {
            sendTo("Laptop");
        }
        if (tvHover) {
            sendTo("TV");
        }
        phoneHover = false;
        laptopHover = false;
        tvHover = false;
        return null;
    }

    override function finishHover(jnlpUrl:String, screenX:Number, screenY:Number, properties:Properties):Rectangle2D {
        return finishHover(null as WidgetInstance, screenX, screenY);
    }
}
