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
            packed: true
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
