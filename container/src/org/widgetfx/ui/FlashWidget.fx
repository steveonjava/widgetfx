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

import org.jdic.web.BrComponent;
import org.jdic.web.event.*;
import org.widgetfx.*;
import javafx.application.*;
import javafx.ext.swing.*;
import javafx.scene.*;
import javafx.lang.DeferredTask;

/**
 * @author Stephen Chin
 */

public class FlashWidget extends Widget, BrComponentListener {
    
    override attribute autoLaunch = false;
    
    override attribute resizable = true;
    
    public attribute url:String;
    
    public attribute quality = "high";
    
    public attribute bgcolor = "#D9D9D9";
    
    public attribute width = "100%";
    
    public attribute height = "100%";

    private attribute player:BrComponent;
    
    public attribute panel:javax.swing.JPanel;
    
    private attribute flashComponent = bind Component.fromJComponent(panel);
    
    private attribute html = bind
"<html><body border=\"no\" scroll=\"no\" style=\"margin: 0px 0px 0px 0px;\">
<object id=\"flash\" style=\"margin: 0px 0px 0px 0px; width:{width}; height:{height}\" classid=\"clsid:D27CDB6E-AE6D-11cf-96B8-444553540000\" codebase=\"http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=6,0,29,0\">
    <param name=\"movie\" value=\"{url}\">
    <param name=\"quality\" value=\"{quality}\">
    <param name=bgcolor VALUE={bgcolor}>
</object>
</body></html>";
    
    init {
        BrComponent.DESIGN_MODE = false;
        BrComponent.setDefaultPaintAlgorithm(BrComponent.PAINT_NATIVE);
        createPlayer();
    }
    
    private function createPlayer() {
        panel = new javax.swing.JPanel(new java.awt.GridLayout(1, 1));
        player = new BrComponent();
        player.addBrComponentListener(this);
        player.setPreferredSize(new java.awt.Dimension(stage.width, stage.height));
        player.setHTML(new java.io.StringBufferInputStream(html), url);
        panel.add(player);
    }
    
    
    public function sync(event:BrComponentEvent):String {
        if (event.getID() == event.DISPID_DOCUMENTCOMPLETE) {
//            updatePlayerSize();
//            DeferredTask {
//                action: function() {
//                    flashPlayer.execJS(":document.getElementById('flash').login();");
//                }
//            }
        }
        return null;
    }
    
    private attribute stageWidth = 300;
    
    private attribute stageHeight = 300;
    
    override attribute onDock = function() {
        createPlayer();
    }
    
    override attribute onUndock = function() {
        createPlayer();
    }
    
    override attribute stage = Stage {
        width: bind stageWidth with inverse
        height: bind stageHeight with inverse
        content: javafx.scene.geometry.Rectangle {width: bind stageWidth, height: bind stageHeight, fill: bind javafx.scene.paint.Color.BLUE}
    }
}
