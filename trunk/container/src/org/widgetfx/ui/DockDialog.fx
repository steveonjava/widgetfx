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
package org.widgetfx.ui;

import java.awt.AWTException;
import java.awt.Point;
import java.awt.SystemTray;
import java.awt.TrayIcon;
import java.awt.event.ActionListener;
import java.awt.GraphicsEnvironment;
import java.util.Timer;
import java.util.TimerTask;
import java.util.*;
import javafx.scene.*;
import javafx.scene.input.*;
import javafx.scene.paint.*;
import javafx.stage.*;
import javafx.scene.shape.Rectangle;
import org.jfxtras.menu.*;
import org.jfxtras.stage.*;
import org.widgetfx.*;
import org.widgetfx.config.*;
import org.widgetfx.install.InstallUtil;
import java.awt.AWTEvent;
import java.awt.Toolkit;
import java.awt.event.AWTEventListener;

import javax.swing.SwingUtilities;

import java.awt.Component;

var menuHeight = if (WidgetFXConfiguration.IS_MAC) 22 else 0;
var DEFAULT_WIDTH = 180;
var MIN_WIDTH = 120;
var MAX_WIDTH = 400;
public def DS_RADIUS = 5;

var instance:DockDialog;

public function createInstance() {
    instance = DockDialog {
        style: if (WidgetFXConfiguration.TRANSPARENT) StageStyle.TRANSPARENT else StageStyle.UNDECORATED
    }
}

public function getInstance() {
    return instance;
}

/**
 * @author Stephen Chin
 */
public class DockDialog extends JFXDialog {

    override var title = "WidgetFX";
    override var visible = true;
    override var width = DEFAULT_WIDTH + DockSkin.BORDER * 2;

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
        }
    ]);

    var currentGraphics:java.awt.GraphicsConfiguration on replace {
        updateDockLocation(true);
    }
    var screenBounds:java.awt.Rectangle;
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
    package var dockLeft:Boolean on replace {
        dockRight = not dockLeft;
        updateDockLocation(true);
    };
    package var dockRight:Boolean on replace {
        dockLeft = not dockRight;
        updateDockLocation(true);
    };

    var launchOnStartup:Boolean = true on replace {
        if (launchOnStartup) {
            InstallUtil.copyStartupFile();
        } else {
            InstallUtil.deleteStartupFile();
        }
    }

    function updateDockLocation(recalculate:Boolean):Void {
        if (recalculate) {
            screenBounds = currentGraphics.getBounds();
        }
        height = screenBounds.height - menuHeight;
        x = screenBounds.x + (if (dockLeft) 0 else screenBounds.width - width);
        y = screenBounds.y + menuHeight;
    }

    var widthTrigger = bind width on replace {
        updateDockLocation(false);
    }

    function getGraphicsConfiguration(location:Point) {
        if (not dockSkin.container.dragging and not resizing) {
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

    var mainMenu:NativePopupMenu;

    var dockSkin = DockSkin {
        dockDialog: this
        width: bind width
        height: bind height
    }

    package var mouseOver:Boolean;

    package var draggingDock:Boolean;

    package var resizing:Boolean;

    postinit {
        mainMenu = createNativeMainMenu(dialog);
        configuration.load();
        loadContent();
        createTrayIcon();
        WidgetManager.getInstance().dockOffscreenWidgets();
        watchDisplayResolution();
    }

    function watchDisplayResolution() {
        (new Timer("displayMonitor")).schedule(TimerTask {
            override function run() {
                if (not screenBounds.equals(currentGraphics.getBounds())) {
                    FX.deferAction(function():Void {
                        updateDockLocation(true);
                    });
                }
            }
        }, 0, 3000);
    }

    function hideDock() {
        visible = false;
    }

    public function showDock() {
        visible = true;
        FX.deferAction(function() {updateDockLocation(true)});
        toFront();
        WidgetManager.getInstance().dockOffscreenWidgets();
    }

    public function showDockAndWidgets() {
        showDock();
        for (instance in WidgetManager.getInstance().widgets where instance.frame != null) {
            instance.frame.toFront();
        }
    }

    package var tray:TrayIcon;

    function createTrayIcon() {
        tray = new TrayIcon(dockSkin.logoIcon);
        tray.setPopupMenu(createNativeMainMenu(null).getPopupMenu());
        tray.setToolTip("WidgetFX v{WidgetFXConfiguration.VERSION}");
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

    public function addWidget():Void {
        AddWidgetDialog {
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
                NativeMenuItem {
                    text: "Clear Stylesheets"
                    action: function() {
                        WidgetManager.getInstance().clearStylesheets();
                    }
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

    public function showMenu(x:Integer, y:Integer) {
        mainMenu.show(dialog, x, y);
    }

    public function resizeDragged(e:MouseEvent):Void {
        resizing = true;
        var draggedWidth = if (dockLeft) e.screenX.intValue() - screenBounds.x
                else screenBounds.x + screenBounds.width - e.screenX.intValue();
        width = if (draggedWidth < MIN_WIDTH) MIN_WIDTH else if (draggedWidth > MAX_WIDTH) MAX_WIDTH else draggedWidth;
    }

    public function resizeReleased(e:MouseEvent):Void {
        resizing = false;
    }

    var leftBG = bind LinearGradient {
        endY: 0
        stops: [
            Stop {offset: 0.0, color: dockSkin.backgroundEndColor},
            Stop {offset: 1.0, color: dockSkin.backgroundStartColor}
        ]
    }
    var rightBG = bind LinearGradient {
        endY: 0
        stops: [
            Stop {offset: 0.0, color: dockSkin.backgroundStartColor},
            Stop {offset: 1.0, color: dockSkin.backgroundEndColor}
        ]
    }
    var transparentBG = bind if (dockLeft) leftBG else rightBG;

    function loadContent():Void {
        onClose = function() {WidgetManager.getInstance().exit()};
        scene = Scene {
//            stylesheets: bind WidgetManager.getInstance().stylesheets
            content: [
                Rectangle {
                    width: bind width
                    height: bind height
                    fill: bind transparentBG
                    opacity: bind dockSkin.rolloverOpacity
                },
                dockSkin
            ]
            fill: Color.TRANSPARENT
        }

        Toolkit.getDefaultToolkit().addAWTEventListener(AWTEventListener {
            override function eventDispatched(event:AWTEvent):Void {
                if (not SwingUtilities.isDescendingFrom(event.getSource() as Component, dialog)) {
                    return;
                }
                if (event.getID() == java.awt.event.MouseEvent.MOUSE_ENTERED) {
                    mouseOver = true;
                } else if (event.getID() == java.awt.event.MouseEvent.MOUSE_EXITED) {
                    mouseOver = false;
                } else if (event.getID() == java.awt.event.MouseEvent.MOUSE_RELEASED) {
                    draggingDock = false;
                } else if (event.getID() == java.awt.event.MouseEvent.MOUSE_DRAGGED) {
                    draggingDock = true;
                    getGraphicsConfiguration((event as java.awt.event.MouseEvent).getLocationOnScreen());
                }
            }
        }, AWTEvent.MOUSE_EVENT_MASK + AWTEvent.MOUSE_MOTION_EVENT_MASK);
    }
}
