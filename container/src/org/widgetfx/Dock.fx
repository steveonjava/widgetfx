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
import org.jfxtras.menu.*;
import org.jfxtras.stage.*;
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
import java.awt.image.*;
import java.awt.GraphicsEnvironment;
import java.util.Timer;
import java.util.TimerTask;
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
var instance:Dock;

public function createInstance() {
    instance = Dock {};
}

public function getInstance() {
    return instance;
}

public class Dock extends Dialog {
//    var logoX:Number = 12;
//    var logoY:Number = 7;
//    var logoUrl:String = "{__DIR__}images/WidgetFX-Logo.png";
    var logoX:Number = -59;
    var logoY:Number = 6;
    var logoUrl:String = "{__DIR__}images/logo_6thspace.png";
//    var backgroundStartColor = [0.0, 0.0, 0.0, 0.0];
//    var backgroundEndColor = [0.0, 0.0, 0.0, 0.7];
    var backgroundStartColor = [0.0, 0.0, 0.0, 0.2];
    var backgroundEndColor = [0.0, 0.0, 0.0, 0.2];
    
    var themeProperties = [
        NumberProperty {
            name: "logoX"
            value: bind logoX with inverse;
        },
        NumberProperty {
            name: "logoY"
            value: bind logoY with inverse;
        },
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
    
    var mainMenu:NativePopupMenu;
    var logo:Node = Group {
        translateX: bind if (logoX < 0) width + logoX else logoX
        translateY: bind logoY
        effect: bind if (logo.hover) Glow {level: 0.7} else null
        var imageView = ImageView {
            image: bind Image {
                url: if (theme.isEmpty()) {
                    logoUrl
                } else {
                    // resolve the logoUrl against the theme
                    (new URL(new URL(theme), logoUrl)).toString()
                }
            }
        }
        content: [
            Rectangle {
                width: bind imageView.boundsInLocal.width
                height: bind imageView.boundsInLocal.height
                fill: Color.TRANSPARENT
            },
            imageView
        ]
        onMouseReleased: function(e:MouseEvent) {
            mainMenu.show(dialog, e.sceneX, e.sceneY);
        }
    }
    var headerHeight:Integer = bind BORDER * 2 + logo.boundsInLocal.height.intValue();
    var deviceBar:DeviceBar = DeviceBar {
        translateX: bind (width - deviceBar.layoutBounds.width) / 2
        translateY: bind height - 87
        opacity: bind rolloverOpacity
    }
    
    var container:WidgetContainer = WidgetContainer {
        window: bind dialog
        rolloverOpacity: bind rolloverOpacity
        drawShadows: bind not resizing
        translateX: BORDER
        translateY: bind headerHeight
        widgets: bind WidgetManager.getInstance().widgets with inverse
        width: bind width - BORDER * 2
        height: bind height - headerHeight
        layout: GapVBox {}
        visible: bind visible
    }

    var currentGraphics:java.awt.GraphicsConfiguration on replace {
        updateDockLocation(true);
    }
    var screenBounds;
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
        updateDockLocation(true);
    };
    var dockRight:Boolean on replace {
        dockLeft = not dockRight;
        updateDockLocation(true);
    };

    var widthTrigger = bind width on replace {
        updateDockLocation(false);
    }
    
    package var resizing:Boolean;
    
    function updateDockLocation(recalculate:Boolean):Void {
        if (recalculate) {
            screenBounds = currentGraphics.getBounds();
        }
        height = screenBounds.height - menuHeight;
        x = screenBounds.x + (if (dockLeft) 0 else screenBounds.width - width);
        y = screenBounds.y + menuHeight;
    }
    
    var startColor = bind Color.color(backgroundStartColor[0], backgroundStartColor[1], backgroundStartColor[2], rolloverOpacity * (if (backgroundStartColor.size() < 4) 1 else backgroundStartColor[3]));
    var endColor = bind Color.color(backgroundEndColor[0], backgroundEndColor[1], backgroundEndColor[2], rolloverOpacity * (if (backgroundEndColor.size() < 4) 1 else backgroundEndColor[3]));
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
    
    package var rolloverOpacity = 0.0;
    package var rolloverTimeline = Timeline {
        keyFrames: at (500ms) {rolloverOpacity => 1 tween Interpolator.EASEIN}
    }

    var mouseOver:Boolean;

    var draggingDock:Boolean;
    
    var hoverDock = bind mouseOver or container.widgetDragging or draggingDock or resizing on replace oldValue {
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
        var dragBar:Group;
        scene = Scene {
            content: [
                logo,
                deviceBar,
                container,
                dragBar = Group { // Drag Bar
                    blocksMouse: true
                    content: [
                        Line {endY: bind height, stroke: Color.BLACK, strokeWidth: 1, opacity: bind rolloverOpacity * .175},
                        Line {endY: bind height, stroke: Color.BLACK, strokeWidth: 1, opacity: bind rolloverOpacity * .7, translateX: 1},
                        Line {endY: bind height, stroke: Color.WHITE, strokeWidth: 1, opacity: bind rolloverOpacity * .23, translateX: 2}
                    ]
                    translateX: bind if (dockLeft) width - dragBar.boundsInLocal.width else 0
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
