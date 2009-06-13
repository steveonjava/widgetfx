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
package org.widgetfx.widgets;

import java.io.*;
import java.lang.*;
import javafx.scene.*;
import javafx.scene.paint.*;
import javafx.scene.shape.*;
import javax.swing.JPanel;
import org.jdic.web.BrComponent;
import org.jdic.web.event.*;
import org.widgetfx.*;
import org.widgetfx.install.InstallUtil;
import org.widgetfx.ui.*;

/**
 * @author Stephen Chin
 */

public class FlashWidget extends Widget, BrComponentListener {
    
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
    
    override var content =  Rectangle {width: bind width, height: bind height, fill: Color.rgb(0xD9, 0xD9, 0xD9)}
}
