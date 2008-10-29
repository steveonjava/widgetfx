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
import org.widgetfx.install.InstallUtil;
import java.io.*;
import javafx.application.*;
import javafx.ext.swing.*;
import javafx.scene.*;
import javafx.scene.paint.*;
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
    
    private attribute flashComponent = bind Component.fromJComponent(panel) on replace {
        java.lang.System.out.println("created a new flashComponent");
    }
    
    init {
        BrComponent.DESIGN_MODE = false;
        BrComponent.setDefaultPaintAlgorithm(BrComponent.PAINT_NATIVE);
        createPlayer();
    }
    
    private function createHTML(resource:String):String {
        var stream = getClass().getResourceAsStream(resource);
        var tm = File.createTempFile("flash", ".htm");
        InstallUtil.copyStream(stream, new FileOutputStream(tm));
        tm.deleteOnExit();
        return tm.toURL().toString();
    }
    
    private function createPlayer() {
        panel = new javax.swing.JPanel(new java.awt.GridLayout(1, 1));
        player = new BrComponent();
        player.addBrComponentListener(this);
        player.setPreferredSize(new java.awt.Dimension(stage.width, stage.height));
        player.setURL(createHTML("flash.html"));
        panel.add(player);
    }
    
    private attribute loaded = false;
    
    public function processJSEvents(st:String) {
        var args = st.split(",");
        var type = args[1].toLowerCase();
        if (type.equals("loaded")) {
            java.lang.System.out.println("loading");
            player.execJS(":document.getElementById('flash').movie=\"{url}\"");
        } else if (type.equals("getCredentials")) {
            java.lang.System.out.println("getting credentials...");
        }
    }
    
    public function sync(event:BrComponentEvent):String {
        if (BrComponentEvent.DISPID_STATUSTEXTCHANGE == event.getID()) {
            java.lang.System.out.print("got a status text change");
            var st = event.getValue();
            java.lang.System.out.println("with value: {st}");
            if (st.startsWith("javaevent,")) {
                processJSEvents(st);
                //block message echo
                player.execJS(":window.status=\"\"");
            }
        }
        return null;
    }
    
//    override attribute onDock = function() {
//        java.lang.System.out.println("dock called");
//        loaded = false;
//    }
//    
//    override attribute onUndock = function() {
//        java.lang.System.out.println("undock called");
//        player.execJSLater(":document.getElementById('flash').movie=\"{url}\"");
//    }
    
    public function configure() {
        player.execJSLater(":document.getElementById('flash').login()");
    }
    
    private attribute stageWidth = 300;
    
    private attribute stageHeight = 300;
    
    override attribute stage = Stage {
        width: bind stageWidth with inverse
        height: bind stageHeight with inverse
        content: javafx.scene.geometry.Rectangle {width: bind stageWidth, height: bind stageHeight, fill: Color.rgb(0xD9, 0xD9, 0xD9)}
    }
}
