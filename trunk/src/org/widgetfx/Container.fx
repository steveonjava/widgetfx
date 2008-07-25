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
import java.awt.event.MouseAdapter;
import java.awt.event.MouseMotionAdapter;
import com.sun.javafx.runtime.sequence.Sequence;
import com.sun.javafx.runtime.sequence.Sequences;
import com.sun.javafx.runtime.Entry;
import java.util.Arrays;
import java.awt.Point;

/**
 * @author Stephen Chin
 */
public class Container extends Frame {
    static attribute DEFAULT_WIDTH = 180;
    static attribute MIN_WIDTH = 120;
    static attribute MAX_WIDTH = 400;
    static attribute BORDER = 5;
    static attribute DS_RADIUS = 10;
    
    private attribute currentGraphics:java.awt.GraphicsConfiguration;
    private attribute screenBounds = bind currentGraphics.getBounds() on replace {
        updateDockLocation();
    }
    private attribute dockLeft:Boolean on replace {
        updateDockLocation();
    };
    private attribute dragging:Boolean;
    
    private function updateDockLocation() {
        height = screenBounds.height;
        x = screenBounds.x + (if (dockLeft) then 0 else screenBounds.width - width);
        y = screenBounds.y;
    }
    
    public attribute preferredWidth = DEFAULT_WIDTH + BORDER * 2;
    
    private attribute transparentBG = bind if (dockLeft) then leftBG else rightBG;
    private attribute leftBG = LinearGradient {
        endY: 0
        stops: [
            Stop {offset: 0.0, color: Color.color(0, 0, 0, .5)},
            Stop {offset: 1.0, color: Color.color(0, 0, 0, 0)}
        ]
    }
    private attribute rightBG = LinearGradient {
        endY: 0
        stops: [
            Stop {offset: 0.0, color: Color.color(0, 0, 0, 0)},
            Stop {offset: 1.0, color: Color.color(0, 0, 0, .7)}
        ]
    }
    
    init {
        windowStyle = WindowStyle.TRANSPARENT;
        width = preferredWidth;
        currentGraphics = java.awt.GraphicsEnvironment.getLocalGraphicsEnvironment().getDefaultScreenDevice().getDefaultConfiguration();
    }

    postinit {
        loadWidgets();
        loadContent();
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
            cache: true
            content: Group {
                effect: DropShadow {offsetX: 2, offsetY: 2, radius: DS_RADIUS}
                content: Group {
                    content: app.stage.content
                    clip: Rectangle {width: bind app.stage.width, height: bind app.stage.height}
                }
            }
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
                    dragging = true;
                    var xPos = e.getScreenX().intValue() - e.getX().intValue();
                    var yPos = e.getScreenY().intValue() - e.getY().intValue();
                    dockedParent = group.getParent() as Group;
                    dockedParent.content = null;
                    parent = WidgetFrame {
                        widget: app;
                        wrapper: group;
                        x: xPos, y: yPos
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
                dragging = false;
                if (not docked and e.getScreenX() >= x and e.getScreenX() < x + width and e.getScreenY() >= y and e.getScreenY() < y + height) {
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
            autoReverse: true, toggle: true
            keyFrames: KeyFrame {time: 1s, values: rolloverOpacity => 0.8 tween Interpolator.EASEBOTH}
        }
        stage = Stage {
            content: [
                Group { // Drag Bar
                    content: [
                        Line {endY: bind height, stroke: Color.BLACK, strokeWidth: 1, opacity: bind rolloverOpacity / 4},
                        Line {endY: bind height, stroke: Color.BLACK, strokeWidth: 1, opacity: bind rolloverOpacity, translateX: 1},
                        Line {endY: bind height, stroke: Color.WHITE, strokeWidth: 1, opacity: bind rolloverOpacity / 3, translateX: 2}
                    ]
                    horizontalAlignment: bind if (dockLeft) then HorizontalAlignment.TRAILING else HorizontalAlignment.LEADING
                    translateX: bind if (dockLeft) then width else 0
                    cursor: Cursor.H_RESIZE
                    onMouseDragged: function(e:MouseEvent) {
                        dragging = true;
                        width = if (dockLeft) then e.getScreenX().intValue() - screenBounds.x
                                else screenBounds.x + screenBounds.width - e.getScreenX().intValue();
                        width = if (width < MIN_WIDTH) then MIN_WIDTH else if (width > MAX_WIDTH) then MAX_WIDTH else width;
                        updateDockLocation();
                        for (widget in widgets) {
                            if (widget.resizable) {
                                widget.stage.width = width - BORDER * 2;
                            }
                        }
                    }
                    onMouseReleased: function(e) {
                        dragging = false;
                    }
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
                            Group {
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
                }
            ],
            fill: bind transparentBG;
        };
        (window as RootPaneContainer).getContentPane().addMouseListener(MouseAdapter {
            public function mouseEntered(e) {
                rolloverTimeline.start();
            }
            public function mouseExited(e) {
                rolloverTimeline.start();
            }
        });
        (window as RootPaneContainer).getContentPane().addMouseMotionListener(MouseMotionAdapter {
            public function mouseDragged(e) {
                getGraphicsConfiguration(e.getLocationOnScreen());
            }
        });
    }
    
    private function getGraphicsConfiguration(location:Point) {
        if (not dragging) {
            if (not screenBounds.contains(location)) {
                for (gd in Arrays.asList(java.awt.GraphicsEnvironment.getLocalGraphicsEnvironment().getScreenDevices())) {
                    for (gc in Arrays.asList(gd.getConfigurations())) {
                        if (gc.getBounds().contains(location)) {
                            currentGraphics = gc;
                        }
                    }
                }
            }
            dockLeft = location.x < screenBounds.width / 2 + screenBounds.x;
        }
    }
}
