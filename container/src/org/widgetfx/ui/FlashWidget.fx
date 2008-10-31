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
import java.awt.EventQueue;
import java.awt.Point;
import java.awt.event.MouseEvent;
import java.io.*;
import java.lang.*;
import javafx.application.*;
import javafx.ext.swing.*;
import javafx.scene.*;
import javafx.scene.paint.*;
import javafx.lang.DeferredTask;
import javax.swing.SwingUtilities;

/**
 * @author Stephen Chin
 */

public class FlashWidget extends Widget, BrComponentListener {
    
    override attribute autoLaunch = false;
    
    override attribute resizable = true;
    
    public attribute url:String;
    
    public attribute hover = false;
    
    public attribute dragging = false;
    
    private attribute player:BrComponent;
    
    public attribute panel:javax.swing.JPanel;
    
    public attribute dragContainer:DragContainer;
    
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
    
    private function getXY(args:String[]):Integer[] {
        return [Integer.parseInt(args[2]), Integer.parseInt(args[3])];
    }
    
    private attribute gone = false;
    
    public function processJSEvents(st:String) {
        var args = st.split(",");
        var type = args[1].toLowerCase();
        var eventQueue = java.awt.Toolkit.getDefaultToolkit().getSystemEventQueue();
        if (type.equals("loaded")) {
            player.execJS(":setMovie(\"{url}\")");
        } else if (type.equals("requestlogin")) {
            DeferredTask {
                action: function() {
                    Login {
                        token: args[2]
                        forceLogin: Boolean.valueOf(args[3]);
                        onLogin: function(username, password) {
                            player.execJSLater(":login('{username}','{password}')");
                        }
                    }
                }
            }
        } else if (type.equals("inconfiguration")) {
            inConfigure = Boolean.valueOf(args[2]);
            java.lang.System.out.println("inConfigure: {inConfigure}");
        } else if (type.equals("mouseover")) {
            DeferredTask {
                action: function() {
                    hover = true;
                }
            }
        } else if (type.equals("mouseout")) {
            DeferredTask {
                action: function() {
                    hover = false;
                }
            }
            var coords = getXY(args);
            if (coords == [-1, -1]) {
                gone = true;
                DeferredTask {
                    action: function() {
                        if (gone) {
                            dragging = false;
                            var pt = java.awt.MouseInfo.getPointerInfo().getLocation();
                            dragContainer.finishDrag(pt.x, pt.y);
                        }
                    }
                }
            }
        } else if (type.equals("mousedown")) {
            var coords = getXY(args);
            dragging = true;
            DeferredTask {
                action: function() {
                    var pt = java.awt.MouseInfo.getPointerInfo().getLocation();
                    dragContainer.prepareDrag(coords[0], coords[1], pt.x, pt.y);
                }
            }
        } else if (type.equals("mouseup")) {
            var coords = getXY(args);
            dragging = false;
            DeferredTask {
                action: function() {
                    var pt = java.awt.MouseInfo.getPointerInfo().getLocation();
                    dragContainer.finishDrag(pt.x, pt.y);
                }
            }
        } else if (type.equals("mousemove")) {
            gone = false;
            if (dragging) {
                var coords = getXY(args);
                DeferredTask {
                    action: function() {
                        var pt = java.awt.MouseInfo.getPointerInfo().getLocation();
                        dragContainer.doDrag(pt.x, pt.y);
                    }
                }
            }
        } else {
            System.err.println("Unknown javascript command: " + st);
        }
    }
    
    public function sync(event:BrComponentEvent):String {
        if (BrComponentEvent.DISPID_STATUSTEXTCHANGE == event.getID()) {
            var st = event.getValue();
            if (st.startsWith("javaevent,")) {
                processJSEvents(st);
                //block message echo
                player.execJS(":window.status=\"\"");
            }
        }
        return null;
    }
    
    private attribute inConfigure = false;
    
    public function configure():Void {
        player.execJSLater(":toggleConfiguration()");
        inConfigure = not inConfigure;
    }
    
    private attribute stageWidth = 300;
    
    private attribute stageHeight = 300;
    
    override attribute stage = Stage {
        width: bind stageWidth with inverse
        height: bind stageHeight with inverse
        content: javafx.scene.geometry.Rectangle {width: bind stageWidth, height: bind stageHeight, fill: Color.rgb(0xD9, 0xD9, 0xD9)}
    }
}
