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

 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
package org.widgetfx;
import java.lang.Class;
import org.widgetfx.widget.*;
import javafx.scene.paint.*;
import javafx.application.*;
import javafx.application.Frame;
import javafx.scene.*;
import javafx.scene.geometry.*;
import javafx.scene.effect.*;
import javafx.input.*;
import javax.swing.*;
import javafx.scene.text.*;
import javafx.scene.layout.*;
import javafx.ext.swing.*;
import javafx.animation.*;
import com.sun.javafx.runtime.sequence.Sequence;
import com.sun.javafx.runtime.sequence.Sequences;
import com.sun.javafx.runtime.Entry;

/**
 * @author Stephen Chin
 */
public class Container extends Frame {
    static attribute SCREEN_BOUNDS = java.awt.GraphicsEnvironment.getLocalGraphicsEnvironment().getDefaultScreenDevice().getDefaultConfiguration().getBounds();
    static attribute SCREEN_WIDTH = SCREEN_BOUNDS.width;
    static attribute SCREEN_HEIGHT = SCREEN_BOUNDS.height;
    static attribute DEFAULT_WIDTH = 150;
    static attribute BORDER = 4;
    static attribute DS_RADIUS = 10;
    
    public attribute preferredWidth = DEFAULT_WIDTH + BORDER * 2;
    
    private attribute transparentBG = LinearGradient {
        endY: 0
        stops: [
            Stop {offset: 0.0, color: Color.color(0, 0, 0, 0)},
            Stop {offset: 1.0, color: Color.color(0, 0, 0, .5)}
        ]
    }
    private attribute solidBG = LinearGradient {
        endY: 0
        stops: [
            Stop {offset: 0.0, color: Color.SLATEGRAY},
            Stop {offset: 1.0, color: Color.BLACK}
        ]
    }
    
    init {
        windowStyle = WindowStyle.TRANSPARENT;
        dockRight();
    }

    postinit {
        loadWidgets();
        loadContent();
    }
    
    public function dockRight():Void {
        width = preferredWidth;
        height = SCREEN_HEIGHT;
        x = SCREEN_WIDTH - width;
    }

    attribute widgets:Widget[];
    attribute widgetViews:Group[];
    attribute slideShow:Group;
    attribute rss:Group;

    private function loadWidgets():Void {
        widgets = [
            loadWidget("org.widgetfx.widget.Clock"),
            loadWidget("org.widgetfx.widget.SlideShow"),
            loadWidget("org.widgetfx.widget.WebFeed")
        ];
        widgetViews = for (widget in widgets) {
            createWidgetView(widget);
        };
    }
    
    private function loadWidget(widgetClassName:String) {
        var widgetClass:Class = Class.forName(widgetClassName);
        var name = Entry.entryMethodName();
        var args = Sequences.make(java.lang.String.<<class>>) as java.lang.Object;
        return widgetClass.getMethod(name, Sequence.<<class>>).invoke(null, args) as Widget;
    }
    
    public function createWidgetView(app:Widget):Group {
        if (app.onStart <> null) app.onStart();
        var group:Group = Group {
            content: Group {
                content: app.stage.content
                clip: Rectangle {width: bind app.stage.width, height: bind app.stage.height}
            }
            cache: true
            effect: DropShadow {offsetX: 2, offsetY: 2, radius: DS_RADIUS}
            var docked = true
            var dockedParent : Group
            var parent : Frame
            var lastScreenPosX : Integer
            var lastScreenPosY : Integer
            onMousePressed: function(e:MouseEvent):Void {
                lastScreenPosX = e.getScreenX().intValue();
                lastScreenPosY = e.getScreenY().intValue();
            }
            onMouseClicked: function(e:MouseEvent):Void {
                if (e.getButton() == 3) {
                    Dialog {
                        stage: Stage {
                            content: [
                                ComponentView {
                                    component: app.config
                                }
                            ]
                        }
                        visible: true
                    }
                }
            }
            onMouseDragged: function(e:MouseEvent):Void {
                if (docked) {
                    var xPos = e.getScreenX().intValue() - e.getX().intValue();
                    var yPos = e.getScreenY().intValue() - e.getY().intValue();
                    dockedParent = group.getParent() as Group;
                    dockedParent.content = null;
                    parent = Frame {
                        windowStyle: WindowStyle.TRANSPARENT
                        x: xPos
                        y: yPos
                        width: app.stage.width
                        height: app.stage.height
                        title: app.name
                        stage: Stage {content: group, fill: null}
                        visible: true
                        opacity: 0.7
                    }
                    docked = false;
                } else {
                    parent.x += e.getScreenX().intValue() - lastScreenPosX;
                    parent.y += e.getScreenY().intValue() - lastScreenPosY;
                    lastScreenPosX = e.getScreenX().intValue();
                    lastScreenPosY = e.getScreenY().intValue();
                }
            }
            onMouseReleased: function(e:MouseEvent):Void {
                if (not docked and e.getScreenX() > x) {
                    parent.stage = null;
                    parent.close();
                    dockedParent.content = [group];
                    docked = true;
                }
            }
        }
        return group;
    }
    
    public function loadContent():Void {
        var rolloverOpacity = 0.01;
        var rolloverTimeline = Timeline {
            autoReverse: true
            toggle: true
            
            keyFrames: [
                KeyFrame {time: 0ms, values: rolloverOpacity => 0.01},
                KeyFrame {time: 300ms, values: rolloverOpacity => 0.8 tween Interpolator.LINEAR}
            ]

        }
        var stageFill = transparentBG;
        stage = Stage {
            content: [
                Line { // Drag Bar
                    endY: bind height
                    stroke: Color.BLACK
                    strokeWidth: 3
                    opacity: bind rolloverOpacity
                    onMouseDragged: function(e:MouseEvent):Void {
                        width = width - e.getDragX().intValue();
                        x = x + e.getDragX().intValue();
                        for (widget in widgets) {
                            if (widget.resizable) {
                                widget.stage.width = width - BORDER * 2;
                            }
                        }
                    }
                    cursor: Cursor.H_RESIZE;
                },
                VBox { // Content Area
                    translateX: BORDER, translateY: BORDER
                    spacing: BORDER
                    content: [
                        HBox { // Logo Text
                            content: [
                                Text {
                                    font: Font {style: FontStyle.BOLD_ITALIC}
                                    fill: Color.WHITE
                                    textOrigin: TextOrigin.TOP
                                    content: "Widget"
                                },
                                Text {
                                    font: Font {style: FontStyle.BOLD_ITALIC}
                                    fill: Color.ORANGE
                                    textOrigin: TextOrigin.TOP
                                    content: "FX"
                                }
                            ]
                        },
                        for (widget in widgetViews) {
                            HBox {
                                content: widget
                                horizontalAlignment: HorizontalAlignment.CENTER
                                translateX: bind width / 2 - BORDER + DS_RADIUS
                            }
                        },
                        ComponentView { // Exit Button
                            component: Button {
                                text: "Exit"
                                action: function():Void {java.lang.System.exit(0);}
                            }
                        }
                    ]                
                    onMouseEntered: function(e:MouseEvent):Void {
                        rolloverTimeline.start();
                    }
                    onMouseExited: function(e:MouseEvent):Void {
                        rolloverTimeline.start();
                    }
                }
            ],
            fill: bind stageFill;
        };
    }
}
