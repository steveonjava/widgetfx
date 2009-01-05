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

import java.awt.AWTException;
import java.awt.Point;
import java.awt.SystemTray;
import java.awt.TrayIcon;
import java.awt.event.ActionListener;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseMotionAdapter;
import java.awt.image.*;
import java.awt.GraphicsEnvironment;
import java.util.Timer;
import java.util.TimerTask;
import java.io.*;
import java.lang.*;
import java.net.*;
import java.util.*;
import javafx.animation.*;
import javafx.scene.*;
import javafx.scene.input.*;
import javafx.scene.paint.*;
import javafx.stage.*;
import javax.swing.*;
import org.jfxtras.menu.*;
import org.jfxtras.stage.*;
import org.widgetfx.*;
import org.widgetfx.config.*;
import org.widgetfx.install.InstallUtil;

var menuHeight = if (WidgetFXConfiguration.IS_MAC) 22 else 0;
var DEFAULT_WIDTH = 180;
var MIN_WIDTH = 120;
var MAX_WIDTH = 400;

var instance:DockDialog;

public function createInstance() {
    instance = DockDialog {};
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
    override var style = if (WidgetFXConfiguration.TRANSPARENT) StageStyle.TRANSPARENT else StageStyle.UNDECORATED;
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

    var dock = Dock {
        dockDialog: this
        width: bind width
        height: bind height
    }

    var dockSkin = bind dock.skin as DockSkin;

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

    var rolloverStartColor = bind Color.color(dockSkin.backgroundStartColor.red, dockSkin.backgroundStartColor.blue, dockSkin.backgroundStartColor.green, dockSkin.backgroundStartColor.opacity * rolloverOpacity);
    var rolloverEndColor = bind Color.color(dockSkin.backgroundEndColor.red, dockSkin.backgroundEndColor.blue, dockSkin.backgroundEndColor.green, dockSkin.backgroundEndColor.opacity * rolloverOpacity);

    var leftBG = bind LinearGradient {
        endY: 0
        stops: [
            Stop {offset: 0.0, color: rolloverEndColor},
            Stop {offset: 1.0, color: rolloverStartColor}
        ]
    }
    var rightBG = bind LinearGradient {
        endY: 0
        stops: [
            Stop {offset: 0.0, color: rolloverStartColor},
            Stop {offset: 1.0, color: rolloverEndColor}
        ]
    }
    var transparentBG = bind if (dockLeft) leftBG else rightBG;

    package var rolloverOpacity = 0.0;
    package var rolloverTimeline = Timeline {
        keyFrames: at (500ms) {rolloverOpacity => 1 tween Interpolator.EASEIN}
    }

    var hoverDock = bind mouseOver or dockSkin.container.widgetDragging or draggingDock or resizing on replace oldValue {
        // Defer the action to prevent spurious, alternating updates
        if (hoverDock != oldValue) {
            FX.deferAction(function ():Void {
                    // Check the time to make sure we don't run over the end of the animation and reset it
                    if ((hoverDock and rolloverTimeline.time < 500ms) or (not hoverDock and rolloverTimeline.time > 0s)) {
                        rolloverTimeline.rate = if (hoverDock) 1 else -1;
                        rolloverTimeline.play();
                    }
                }
            )
        }
    }

    function loadContent():Void {
        onClose = function() {WidgetManager.getInstance().exit()};
        scene = Scene {
            stylesheets: bind WidgetManager.getInstance().stylesheets
            content: dock
            fill: bind transparentBG
        };
        (dialog as RootPaneContainer).getContentPane().addMouseListener(MouseAdapter {
            override function mouseEntered(e) {
                mouseOver = true;
            }
            override function mouseExited(e) {
                mouseOver = false;
            }
            override function mouseReleased(e) {
                draggingDock = false;
            }
        });
        (dialog as RootPaneContainer).getContentPane().addMouseMotionListener(MouseMotionAdapter {
            override function mouseDragged(e) {
                draggingDock = true;
                getGraphicsConfiguration(e.getLocationOnScreen());
            }
        });
    }
}
