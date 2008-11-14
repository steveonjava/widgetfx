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
package org.widgetfx;

import com.sun.javafx.stage.WindowStageDelegate;
import org.widgetfx.ui.*;
import org.widgetfx.config.*;
import org.widgetfx.install.InstallUtil;
import org.widgetfx.stage.*;
import javafx.lang.*;
import javafx.scene.*;
import javafx.scene.shape.*;
import javafx.scene.effect.*;
import javafx.scene.image.*;
import javafx.scene.input.*;
import javafx.scene.layout.*;
import javafx.scene.paint.*;
import javafx.scene.text.*;
import javafx.stage.*;
import javax.swing.*;
import javafx.ext.swing.*;
import javafx.animation.*;
import java.awt.AWTException;
import java.awt.Point;
import java.awt.SystemTray;
import java.awt.TrayIcon;
import java.awt.event.ActionListener;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseMotionAdapter;
import java.awt.geom.*;
import java.awt.image.*;
import java.awt.GraphicsEnvironment;
import java.io.*;
import java.lang.*;
import java.net.*;
import java.util.*;

/**
 * @author Stephen Chin
 */
var menuHeight = if (WidgetFXConfiguration.IS_MAC) 22 else 0;
var DEFAULT_WIDTH = 180;
var MIN_WIDTH = 120;
var MAX_WIDTH = 400;
var BORDER = 5;
public var DS_RADIUS = 5;
var BG_OPACITY = 0.7;
var BUTTON_COLOR = Color.rgb(0xA0, 0xA0, 0xA0);
var BUTTON_BG_COLOR = Color.rgb(0, 0, 0, 0.1);
var instance;

public function createInstance() {
    instance = Dock {};
}

public function getInstance() {
    return instance;
}

public class Dock extends Dialog {
    var logoUrl:String;
    var backgroundStartColor = [0.0, 0.0, 0.0];
    var backgroundEndColor = [0.0, 0.0, 0.0];
    
    var themeProperties = [
        StringProperty {
            name: "logoUrl"
            value: bind logoUrl with inverse;
        },
        NumberSequenceProperty {
            name: "backgroundStartColor"
            value: bind backgroundStartColor with inverse;
        },
        NumberSequenceProperty {
            name: "backgroundEndColor"
            value: bind backgroundEndColor with inverse;
        }
    ];
    
    public var theme:String on replace {
        if (not theme.isEmpty()) {
            var savedProperties = Properties {};
            savedProperties.load((new URL(theme)).openStream());
            for (property in themeProperties) {
                if (savedProperties.containsKey(property.name)) {
                    property.setStringValue(savedProperties.get(property.name) as String);
                }
            }
        }
    }
    
    var configuration = WidgetFXConfiguration.getInstanceWithProperties([
        StringProperty {
            name: "displayId"
            value: bind displayId with inverse;
        },
        BooleanProperty {
            name: "dockLeft"
            value: bind dockLeft with inverse;
        },
        NumberProperty {
            name: "width"
            value: bind width with inverse;
        },
        BooleanProperty {
            name: "alwaysOnTop"
            value: bind alwaysOnTop with inverse;
        },
        BooleanProperty {
            name: "launchOnStartup"
            value: bind launchOnStartup with inverse;
        },
        BooleanProperty {
            name: "visible"
            value: bind visible with inverse;
        },
        StringProperty {
            name: "theme"
            value: bind theme with inverse;
        }
    ]);
    
    var mainMenu = createNativeMainMenu(dialog);
    var logo:Node = bind if (logoUrl.isEmpty()) {
        createWidgetFXLogo()
    } else {
        ImageView { // resolve the logoUrl against the theme
            image: Image {url: (new URL(new URL(theme), logoUrl)).toString()}
        }
    }
    var headerHeight:Integer = bind BORDER * 2 + logo.boundsInLocal.height.intValue();
    
    var container:WidgetContainer = WidgetContainer {
        window: bind dialog
        rolloverOpacity: bind rolloverOpacity
        resizing: bind resizing
        translateX: BORDER
        translateY: bind headerHeight
        widgets: bind WidgetManager.getInstance().widgets with inverse
        width: bind width - BORDER * 2
        height: bind height - headerHeight
        layout: GapVBox {}
        visible: bind visible
    }
    
    var currentGraphics:java.awt.GraphicsConfiguration;
    var screenBounds = bind currentGraphics.getBounds() on replace {
        updateDockLocation();
    }
    var displayId:String on replace {
        var newGraphics = GraphicsEnvironment.getLocalGraphicsEnvironment().getDefaultScreenDevice().getDefaultConfiguration();
        for (gd in Arrays.asList(GraphicsEnvironment.getLocalGraphicsEnvironment().getScreenDevices())) {
            if (gd.getIDstring().equals(displayId)) {
                newGraphics = gd.getDefaultConfiguration();
                break;
            }
        }
        currentGraphics = newGraphics;
    }
    var dockLeft:Boolean on replace {
        dockRight = not dockLeft;
        updateDockLocation();
    };
    var dockRight:Boolean on replace {
        dockLeft = not dockRight;
        updateDockLocation();
    };

    var widthTrigger = bind width on replace {
        updateDockLocation();
    }

    var alwaysOnTop:Boolean on replace {
        dialog.setAlwaysOnTop(alwaysOnTop);
    }
    
    package var resizing:Boolean;
    
    function updateDockLocation():Void {
        height = screenBounds.height - menuHeight;
        x = screenBounds.x + (if (dockLeft) 0 else screenBounds.width - width);
        y = screenBounds.y + menuHeight;
    }
    
    var bgOpacity = BG_OPACITY;
    var startColor = bind Color.color(backgroundStartColor[0], backgroundStartColor[1], backgroundStartColor[2], 0);
    var endColor = bind Color.color(backgroundEndColor[0], backgroundEndColor[1], backgroundEndColor[2], bgOpacity);
    var leftBG = bind LinearGradient {
        endY: 0
        stops: [
            Stop {offset: 0.0, color: endColor},
            Stop {offset: 1.0, color: startColor}
        ]
    }
    var rightBG = bind LinearGradient {
        endY: 0
        stops: [
            Stop {offset: 0.0, color: startColor},
            Stop {offset: 1.0, color: endColor}
        ]
    }
    var transparentBG = bind if (dockLeft) leftBG else rightBG;
    
    var launchOnStartup:Boolean = true on replace {
        if (launchOnStartup) {
            InstallUtil.copyStartupFile();
        } else {
            InstallUtil.deleteStartupFile();
        }
    }

    override var title = "WidgetFX";
    override var visible = true;
    override var style = if (WidgetFXConfiguration.TRANSPARENT) StageStyle.TRANSPARENT else StageStyle.UNDECORATED;
    override var width = DEFAULT_WIDTH + BORDER * 2;

    postinit {
        configuration.load();
        loadContent();
        createTrayIcon();
        WidgetManager.getInstance().dockOffscreenWidgets();
    }
    
    function hideDock() {
        visible = false;
    }
    
    public function showDock() {
        visible = true;
        FX.deferAction(function() {updateDockLocation();});
        toFront();
        WidgetManager.getInstance().dockOffscreenWidgets();
    }
    
    public function showDockAndWidgets() {
        showDock();
        for (instance in WidgetManager.getInstance().widgets where instance.frame != null) {
            instance.frame.toFront();
        }
    }
    
    function createTrayIcon() {
        var tray:TrayIcon = new TrayIcon(createImage());
        tray.setPopupMenu(createNativeMainMenu(null).getPopupMenu());
        tray.setToolTip("WidgetFX");
        tray.addActionListener(ActionListener {
                override function actionPerformed(e) {
                    showDockAndWidgets();
                }
        });
        try {
            SystemTray.getSystemTray().add(tray);
        } catch (e:AWTException) {
            e.printStackTrace();
        }
    }
    
    function createImage():java.awt.Image {
        return WidgetFXConfiguration.getInstance().widgetFXIcon16t.bufferedImage;
    }
    
    public function addWidget():Void {
        AddWidgetDialog {
            owner: this
            addHandler: function(jnlpUrl:String):Void {
                WidgetManager.getInstance().addWidget(jnlpUrl);
            }
        }
    }
    
    public function createNativeMainMenu(parent:java.awt.Component):NativePopupMenu {
        return NativePopupMenu {
            parent: parent
            items: [
                NativeMenuItem {
                    text: "Add Widget..."
                    action: addWidget
                },
                NativeMenuSeparator {},
                NativeCheckboxMenuItem {
                    text: "Always on Top"
                    selected: bind alwaysOnTop with inverse;
                },
                if (InstallUtil.startupSupported()) {
                    NativeCheckboxMenuItem {
                        text: "Launch on Startup"
                        selected: bind launchOnStartup with inverse
                    }
                } else {
                    []
                },
                NativeMenuSeparator {},
                NativeMenu {
                    text: "Dock Position"
                    items: [
                        NativeCheckboxMenuItem {
                            text: "Left"
                            selected: bind dockLeft with inverse
                        },
                        NativeCheckboxMenuItem {
                            text: "Right"
                            selected: bind dockRight with inverse
                        }
                    ]
                },
                NativeMenuItem {
                    text: bind if (visible) "Hide" else "Show"
                    action: function() {
                        if (visible) {
                            hideDock();
                        } else {
                            showDock();
                        }
                    }
                },
                NativeMenuSeparator {},
                NativeMenuItem {
                    text: "Reload"
                    action: function() {
                        WidgetManager.getInstance().reload();
                    }
                },
                NativeMenuItem {
                    text: "Exit"
                    action: function() {
                        WidgetManager.getInstance().exit();
                    }
                }
            ]
        }
    }
    
    package var rolloverOpacity = 0.01;
    package var rolloverTimeline = Timeline {
        autoReverse: true
        keyFrames: KeyFrame {time: 1s, values: [rolloverOpacity => BG_OPACITY tween Interpolator.EASEBOTH, bgOpacity => BG_OPACITY * 1.2 tween Interpolator.EASEBOTH]}
    }
    
    function createWidgetFXLogo():Group {
        return Group {
            cache: true
            content: HBox {
                translateX: BORDER, translateY: BORDER + 11
                effect: DropShadow {radius: 5, offsetX: 2, offsetY: 2}
                content: [
                    ImageView {
                        y: -13
                        image: WidgetFXConfiguration.getInstance().widgetFXIcon16
                    },
                    Text {
                        font: Font {oblique: true}
                        fill: Color.WHITE
                        content: " Widget"
                    },
                    Text {
                        x: -3
                        font: Font {embolden: true, oblique: true}
                        fill: Color.ORANGE
                        content: "FX"
                    },
                    Text {
                        x: -3
                        font: Font {oblique: true, size: 9}
                        fill: Color.WHITE
                        content: "v{WidgetFXConfiguration.VERSION}"
                    }
                ]
            }
        }
    }
    
    function loadContent():Void {
        onClose = function() {WidgetManager.getInstance().exit()};
        var addWidgetButton = Group {
            var color = BUTTON_COLOR;
            translateY: 7
            cache: true
            content: [
                Circle {
                    stroke: bind color
                    fill: BUTTON_BG_COLOR;
                    radius: 7
                },
                Line {
                    stroke: bind color
                    strokeWidth: 2
                    startX: -3, startY: 0
                    endX: 3, endY: 0
                },
                Line {
                    stroke: bind color
                    strokeWidth: 2
                    startX: 0, startY: -3
                    endX: 0, endY: 3
                }
            ]
            onMouseEntered: function(e) {
                color = Color.WHITE;
            }
            onMouseExited: function(e) {
                color = BUTTON_COLOR;
            }
            onMouseClicked: function(e) {
                addWidget();
            }
        }
        var mainMenuButton:Group = Group {
            var color = BUTTON_COLOR;
            translateY: 7
            cache: true
            content: [
                Circle {
                    stroke: bind color
                    fill: BUTTON_BG_COLOR;
                    radius: 7
                },
                Polygon {
                    stroke: bind color
                    fill: bind color
                    points: [
                        -3.0,-1.0, 
                        3.0,-1.0,
                        0.0,3.0
                    ]
                }
            ]
            onMouseEntered: function(e) {
                color = Color.WHITE;
            }
            onMouseExited: function(e) {
                color = BUTTON_COLOR;
            }
            onMouseReleased: function(e:MouseEvent) {
                mainMenu.show(dialog, e.sceneX, e.sceneY);
            }
        }
        var hideButton = Group {
            var color = BUTTON_COLOR;
            translateY: 7
            cache: true
            content: [
                Circle {
                    stroke: bind color
                    fill: BUTTON_BG_COLOR;
                    radius: 7
                },
                Line {
                    stroke: bind color
                    strokeWidth: 2
                    startX: -3, startY: 2
                    endX: 3, endY: 2
                }
            ]
            onMouseEntered: function(e) {
                color = Color.WHITE;
            }
            onMouseExited: function(e) {
                color = BUTTON_COLOR;
            }
            onMouseClicked: function(e) {
                hideDock();
            }
        }
        var menus:HBox = HBox { // Menu Buttons
            translateX: bind width - menus.boundsInLocal.width
            translateY: 4
            spacing: 4
            content: [
                addWidgetButton,
                mainMenuButton,
                hideButton
            ]

        }
        scene = Scene {
            content: [
                Group {
                    content: bind logo
                },
                menus,
                container,
                Group { // Drag Bar
                    blocksMouse: true
                    content: [
                        Line {endY: bind height, stroke: Color.BLACK, strokeWidth: 1, opacity: bind rolloverOpacity / 4},
                        Line {endY: bind height, stroke: Color.BLACK, strokeWidth: 1, opacity: bind rolloverOpacity, translateX: 1},
                        Line {endY: bind height, stroke: Color.WHITE, strokeWidth: 1, opacity: bind rolloverOpacity / 3, translateX: 2}
                    ]
                    // todo - fix alignment
                    //horizontalAlignment: bind if (dockLeft) HorizontalAlignment.TRAILING else HorizontalAlignment.LEADING
                    translateX: bind if (dockLeft) width else 0
                    cursor: Cursor.H_RESIZE
                    onMouseDragged: function(e:MouseEvent) {
                        resizing = true;
                        var draggedWidth = if (dockLeft) e.screenX.intValue() - screenBounds.x
                                else screenBounds.x + screenBounds.width - e.screenX.intValue();
                        width = if (draggedWidth < MIN_WIDTH) MIN_WIDTH else if (draggedWidth > MAX_WIDTH) MAX_WIDTH else draggedWidth;
                    }
                    onMouseReleased: function(e) {
                        for (instance in container.dockedWidgets) {
                            if (instance.widget.resizable) {
                                if (instance.widget.onResize != null) {
                                    instance.widget.onResize(instance.widget.width, instance.widget.height);
                                }
                                instance.saveWithoutNotification();
                            }
                        }
                        resizing = false;
                    }
                }
            ],
            fill: bind transparentBG;
        };
        (dialog as RootPaneContainer).getContentPane().addMouseListener(MouseAdapter {
            override function mouseEntered(e) {
                rolloverTimeline.play();
            }
            override function mouseExited(e) {
                rolloverTimeline.play();
            }
        });
        (dialog as RootPaneContainer).getContentPane().addMouseMotionListener(MouseMotionAdapter {
            override function mouseDragged(e) {
                getGraphicsConfiguration(e.getLocationOnScreen());
            }
        });
    }
    
    function getGraphicsConfiguration(location:Point) {
        if (not container.dragging and not resizing) {
            if (not screenBounds.contains(location)) {
                for (gd in Arrays.asList(GraphicsEnvironment.getLocalGraphicsEnvironment().getScreenDevices())) {
                    var gc = gd.getDefaultConfiguration();
                    if (gc.getBounds().contains(location)) {
                        displayId = gd.getIDstring();
                        break;
                    }
                }
            }
            dockRight = not (dockLeft = location.x < screenBounds.width / 2 + screenBounds.x);
        }
    }
}
