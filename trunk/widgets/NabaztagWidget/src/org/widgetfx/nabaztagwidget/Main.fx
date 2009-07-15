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
package org.widgetfx.nabaztagwidget;

import javafx.io.http.HttpRequest;
import javafx.scene.Group;
import javafx.scene.Scene;
import javafx.scene.control.TextBox;
import javafx.scene.layout.LayoutInfo;
import javafx.scene.layout.VBox;
import javafx.scene.paint.Color;
import javafx.scene.shape.Rectangle;
import javafx.scene.text.Text;
import javafx.scene.text.TextOrigin;
import org.widgetfx.Widget;
import org.widgetfx.config.Configuration;
import org.widgetfx.config.StringProperty;
import org.widgetfx.nabaztagwidget.BunnyUI;

/**
 * @author Stephen Chin
 */
var bunny = BunnyUI {
}
var messageBox: TextBox = TextBox {
    blocksMouse: true
    translateX: 210
    translateY: 111
    layoutInfo: LayoutInfo {
        width: 250
        height: 32
    }
    action: sendMessage
}
var serialNumber:String;
var token:String;

function sendMessage():Void {
    println("send");
    HttpRequest {
        location: "http://api.nabaztag.com/vl/FR/api.jsp?sn={serialNumber}&token={token}&voice=US-Darlene&tts={messageBox.text.<<replace>>(" ", "%20")}"
    }.start();
}

bunny.happy.onMouseClicked = function(e) {
    println("happy");
    HttpRequest {
        location: "http://api.nabaztag.com/vl/FR/api.jsp?sn={serialNumber}&token={token}&posleft=0&posright=0"
    }.start();
}
bunny.sad.onMouseClicked = function(e) {
    println("sad");
    HttpRequest {
        location: "http://api.nabaztag.com/vl/FR/api.jsp?sn={serialNumber}&token={token}&posleft=10&posright=10"
    }.start();
}
bunny.dance.onMouseClicked = function(e) {
    println("dance");
    HttpRequest {
        location: "http://api.nabaztag.com/vl/FR/api.jsp?sn={serialNumber}&token={token}&{BunnyGenerator.generateCommand()}"
    }.start();
}
bunny.speak.onMouseClicked = function(e) {
    println("speak");
    HttpRequest {
        location: "http://api.nabaztag.com/vl/FR/api_stream.jsp?sn={serialNumber}&token={token}&urlList=http://projects.joshy.org/demos/BunnyTest/posse.mp3"
    }.start();
}
bunny.send.onMouseClicked = function(e) {
    sendMessage()
}

Widget {
    width: 480
    height: 380
    content: [
        bunny,
        messageBox
    ]
    configuration: Configuration {
        properties: [
            StringProperty {
                name: "serialNumber"
                value: bind serialNumber with inverse
            }
            StringProperty {
                name: "token"
                value: bind token with inverse
            }
        ]
        scene: Scene {
            content: [
                Rectangle {
                    width: 350
                    height: 90
                    fill: Color.TRANSPARENT
                }
                VBox {
                    translateX: 10
                    translateY: 10
                    spacing: 10
                    content: [
                        Group {
                            content: [
                                Text {translateY: 10, content: "Serial Number:", textOrigin: TextOrigin.TOP}
                                TextBox {translateX: 100, columns: 20,  text: bind serialNumber with inverse}
                            ]
                        }
                        Group {
                            content: [
                                Text {translateY: 10, content: "Token:", textOrigin: TextOrigin.TOP}
                                TextBox {translateX: 100, columns: 20,  text: bind token with inverse}
                            ]
                        }
                    ]
                }
            ]
        }
    }
}
