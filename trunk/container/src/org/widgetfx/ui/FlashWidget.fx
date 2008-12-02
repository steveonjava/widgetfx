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
import javafx.ext.swing.*;
import javafx.scene.*;
import javafx.scene.paint.*;
import javafx.scene.shape.*;
import javax.swing.JPanel;
import javax.swing.SwingUtilities;

/**
 * @author Stephen Chin
 */

public class FlashWidget extends Widget, BrComponentListener {
    
    override var autoLaunch = false;
    
    override var resizable = true;
    
    public-init var url:String;
    
    public-read var widgetHovering = false;
    
    public-read var dragging = false;
    
    var player:BrComponent;
    
    public var dragContainer:DragContainer;
    
    init {
        BrComponent.DESIGN_MODE = false;
        BrComponent.setDefaultPaintAlgorithm(BrComponent.PAINT_NATIVE);
    }
    
    function createHTML(resource:String):String {
        var stream = getClass().getResourceAsStream(resource);
        var tm = File.createTempFile("flash", ".htm");
        InstallUtil.copyStream(stream, new FileOutputStream(tm));
        tm.deleteOnExit();
        return tm.toURL().toString();
    }
    
    public function createPlayer():JPanel {
        var panel = new JPanel(new java.awt.GridLayout(1, 1));
        player = new BrComponent();
        player.addBrComponentListener(this);
        player.setPreferredSize(new java.awt.Dimension(width, height));
        player.setURL(createHTML("flash.html"));
        panel.add(player);
        return panel;
    }
    
    var loaded = false;
    
    function getXY(args:String[]):Integer[] {
        return [Integer.parseInt(args[2]), Integer.parseInt(args[3])];
    }
    
    var gone = false;
    
    public function processJSEvents(st:String) {
        var args = st.split(",");
        var type = args[1].toLowerCase();
        var eventQueue = java.awt.Toolkit.getDefaultToolkit().getSystemEventQueue();
        if (type.equals("loaded")) {
            player.execJS(":setMovie(\"{url}\")");
        } else if (type.equals("requestlogin")) {
            FX.deferAction(
                function():Void {
                    Login {
                        token: args[2]
                        forceLogin: Boolean.valueOf(args[3]);
                        onLogin: function(username, password) {
                            player.execJSLater(":login('{username}','{password}')");
                        }
                    }
                }
            );
        } else if (type.equals("inconfiguration")) {
            inConfigure = Boolean.valueOf(args[2]);
        } else if (type.equals("mouseover")) {
            FX.deferAction(
                function():Void {
                    widgetHovering = true;
                }
            );
        } else if (type.equals("mouseout")) {
            FX.deferAction(
                function():Void {
                    widgetHovering = false;
                }
            );
            var coords = getXY(args);
            if (coords == [-1, -1]) {
                gone = true;
                FX.deferAction(
                    function():Void {
                        if (gone) {
                            dragging = false;
                            var pt = java.awt.MouseInfo.getPointerInfo().getLocation();
                            dragContainer.finishDrag(pt.x, pt.y);
                        }
                    }
                );
            }
        } else if (type.equals("mousedown")) {
            var coords = getXY(args);
            dragging = true;
            FX.deferAction(
                function():Void {
                    var pt = java.awt.MouseInfo.getPointerInfo().getLocation();
                    dragContainer.prepareDrag(coords[0], coords[1], pt.x, pt.y);
                }
            );
        } else if (type.equals("mouseup")) {
            var coords = getXY(args);
            dragging = false;
            FX.deferAction(
                function():Void {
                    var pt = java.awt.MouseInfo.getPointerInfo().getLocation();
                    dragContainer.finishDrag(pt.x, pt.y);
                }
            );
        } else if (type.equals("mousemove")) {
            gone = false;
            var button:Integer = Integer.valueOf(args[4]);
            if (dragging) {
                var coords = getXY(args);
                FX.deferAction(
                    function():Void {
                        var pt = java.awt.MouseInfo.getPointerInfo().getLocation();
                        if (button == 0) {
                            dragging = false;
                            dragContainer.finishDrag(pt.x, pt.y);
                        } else {
                            dragContainer.doDrag(pt.x, pt.y);
                        }
                    }
                );
            }
        } else {
            System.err.println("Unknown javascript->java bridge command: {st}");
        }
    }
    
    override function sync(event:BrComponentEvent):String {
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
    
    var inConfigure = false;
    
    public function configure():Void {
        player.execJSLater(":toggleConfiguration()");
        inConfigure = not inConfigure;
    }
    
    override var width = 300;
    
    override var height = 300;
    
    override var content = Rectangle {width: bind width, height: bind height, fill: Color.rgb(0xD9, 0xD9, 0xD9)};
}
