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
import org.widgetfx.ui.*;
import org.widgetfx.config.*;
import org.widgetfx.install.InstallUtil;
import javafx.lang.*;
import javafx.scene.paint.*;
import javafx.application.Stage;
import javafx.application.WindowStyle;
import javafx.scene.*;
import javafx.scene.geometry.*;
import javafx.scene.effect.*;
import javafx.scene.image.*;
import javafx.input.*;
import javax.swing.*;
import javafx.scene.text.*;
import javafx.scene.layout.*;
import javafx.ext.swing.*;
import javafx.animation.*;
import java.awt.AWTException;
import java.awt.Graphics2D;
import java.awt.GraphicsEnvironment;
import java.awt.Point;
import java.awt.SystemTray;
import java.awt.TrayIcon;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseMotionAdapter;
import java.awt.event.ActionListener;
import java.awt.event.ActionEvent;
import java.awt.GraphicsEnvironment;
import java.awt.geom.Ellipse2D;
import java.awt.image.BufferedImage;
import java.util.Arrays;
import java.util.Properties;
import java.util.Timer;
import java.util.TimerTask;
import java.io.*;
import java.lang.*;
import java.net.URL;

/**
 * @author Stephen Chin
 */
public class Dock extends BaseDialog {
    private static attribute menuHeight = if (WidgetFXConfiguration.IS_MAC) 22 else 0;
    private static attribute DEFAULT_WIDTH = 180;
    private static attribute MIN_WIDTH = 120;
    private static attribute MAX_WIDTH = 400;
    static attribute BORDER = 5;
    public static attribute DS_RADIUS = 5;
    private static attribute BG_OPACITY = 0.7;
    private static attribute BUTTON_COLOR = Color.rgb(0xA0, 0xA0, 0xA0);
    private static attribute BUTTON_BG_COLOR = Color.rgb(0, 0, 0, 0.1);
    
    private static attribute instance;
    
    public static function createInstance() {
        instance = Dock {};
    }
    
    public static function getInstance() {
        return instance;
    }
    
    private attribute logoUrl:String;
    private attribute backgroundStartColor = [0.0, 0.0, 0.0];
    private attribute backgroundEndColor = [0.0, 0.0, 0.0];
    
    private attribute themeProperties = [
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
    
    public attribute theme:String on replace {
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
    
    private attribute configuration = WidgetFXConfiguration.getInstanceWithProperties([
        StringProperty {
            name: "displayId"
            value: bind displayId with inverse;
        },
        BooleanProperty {
            name: "dockLeft"
            value: bind dockLeft with inverse;
        },
        IntegerProperty {
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
    
    private attribute mainMenu = createNativeMainMenu(window);
    private attribute logo:Node = bind if (logoUrl.isEmpty()) {
        createWidgetFXLogo()
    } else {
        ImageView { // resolve the logoUrl against the theme
            image: Image {url: (new URL(new URL(theme), logoUrl)).toString()}
        }
    }
    private attribute headerHeight:Integer = bind BORDER * 2 + logo.getHeight().intValue();
    attribute container:WidgetContainer = WidgetContainer {
        window: window
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
    
    private attribute currentGraphics:java.awt.GraphicsConfiguration on replace {
        updateDockLocation(true);
    }
    private attribute screenBounds;
    private attribute displayId:String on replace {
        var newGraphics = GraphicsEnvironment.getLocalGraphicsEnvironment().getDefaultScreenDevice().getDefaultConfiguration();
        for (gd in Arrays.asList(GraphicsEnvironment.getLocalGraphicsEnvironment().getScreenDevices()) where gd.getIDstring().equals(displayId)) {
            newGraphics = gd.getDefaultConfiguration();
            break;
        }
        currentGraphics = newGraphics;
    }
    private attribute dockLeft:Boolean on replace {
        dockRight = not dockLeft;
        updateDockLocation(true);
    };
    private attribute dockRight:Boolean on replace {
        dockLeft = not dockRight;
        updateDockLocation(true);
    };

    private attribute widthTrigger = bind width on replace {
        updateDockLocation(false);
    }

    private attribute alwaysOnTop:Boolean on replace {
        window.setAlwaysOnTop(alwaysOnTop);
    }
    
    attribute resizing:Boolean;
    
    private function updateDockLocation(recalculate:Boolean) {
        if (recalculate) {
            screenBounds = currentGraphics.getBounds();
        }
        height = screenBounds.height - menuHeight;
        x = screenBounds.x + (if (dockLeft) 0 else screenBounds.width - width);
        y = screenBounds.y + menuHeight;
    }
    
    //private attribute backgroundImage : Image = Image {url:getClass().getResource("Inovis_SidebarBackground1.jpg").toString(), height: 1200};
    
    private attribute transparentBG = bind if (dockLeft) leftBG else rightBG;
    private attribute bgOpacity = BG_OPACITY;
    private attribute startColor = bind Color.color(backgroundStartColor[0], backgroundStartColor[1], backgroundStartColor[2], 0);
    private attribute endColor = bind Color.color(backgroundEndColor[0], backgroundEndColor[1], backgroundEndColor[2], bgOpacity);
    private attribute leftBG = bind LinearGradient {
        endY: 0
        stops: [
            Stop {offset: 0.0, color: endColor},
            Stop {offset: 1.0, color: startColor}
        ]
    }
    private attribute rightBG = bind LinearGradient {
        endY: 0
        stops: [
            Stop {offset: 0.0, color: startColor},
            Stop {offset: 1.0, color: endColor}
        ]
    }
    
    private attribute launchOnStartup:Boolean = true on replace {
        if (launchOnStartup) {
            InstallUtil.copyStartupFile();
        } else {
            InstallUtil.deleteStartupFile();
        }
    }

    override attribute title = "WidgetFX";
    override attribute visible = true;
    override attribute windowStyle = if (WidgetFXConfiguration.TRANSPARENT) WindowStyle.TRANSPARENT else WindowStyle.UNDECORATED;
    override attribute width = DEFAULT_WIDTH + BORDER * 2;

    postinit {
        configuration.load();
        loadContent();
        createTrayIcon();
        WidgetManager.getInstance().dockOffscreenWidgets();
        watchDisplayResolution();
    }
    
    private function watchDisplayResolution() {
        (new Timer("displayMonitor")).schedule(TimerTask {
            public function run() {
                if (not screenBounds.equals(currentGraphics.getBounds())) {
                    DeferredTask {
                        action: function() {
                            updateDockLocation(true);
                        }
                    }
                }
            }
        }, 0, 3000);
    }
    
    private function hideDock() {
        visible = false;
    }
    
    public function showDock() {
        visible = true;
        DeferredTask { // workaround for defect where dock moves to center on show
            action: function() {updateDockLocation(true);}
        }
        toFront();
        WidgetManager.getInstance().dockOffscreenWidgets();
    }
    
    public function showDockAndWidgets() {
        showDock();
        for (instance in WidgetManager.getInstance().widgets where instance.frame != null) {
            instance.frame.toFront();
        }
    }
    
    private function createTrayIcon() {
        var tray:TrayIcon = new TrayIcon(createImage());
        tray.setPopupMenu(createNativeMainMenu(null).getPopupMenu());
        tray.setToolTip("WidgetFX");
        tray.addActionListener(ActionListener {
                public function actionPerformed(e) {
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
        return WidgetFXConfiguration.getInstance().widgetFXIcon16t.getBufferedImage();
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
    
    attribute rolloverOpacity = 0.01;
    attribute rolloverTimeline = Timeline {
        autoReverse: true, toggle: true
        keyFrames: KeyFrame {time: 1s, values: [rolloverOpacity => BG_OPACITY tween Interpolator.EASEBOTH, bgOpacity => BG_OPACITY * 1.2 tween Interpolator.EASEBOTH]}
    }
    
    private function createWidgetFXLogo():Group {
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
                        font: Font {style: FontStyle.BOLD_ITALIC}
                        fill: Color.WHITE
                        content: " Widget"
                    },
                    Text {
                        x: -3
                        font: Font {style: FontStyle.BOLD_ITALIC}
                        fill: Color.ORANGE
                        content: "FX"
                    },
                    Text {
                        x: -3
                        font: Font {style: FontStyle.ITALIC, size: 9}
                        fill: Color.WHITE
                        content: "v{WidgetFXConfiguration.VERSION}"
                    }
                ]
            }
        }
    }
    
    private function loadContent():Void {
        closeAction = function() {WidgetManager.getInstance().exit()};
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
                mainMenu.show(window, e.getStageX().intValue(), e.getStageY().intValue());
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
        var menus = HBox { // Menu Buttons
            translateX: bind width, translateY: 4
            spacing: 4
            horizontalAlignment: HorizontalAlignment.TRAILING
            content: [
                addWidgetButton,
                mainMenuButton,
                hideButton
            ]

        }
        stage = Stage {
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
                    horizontalAlignment: bind if (dockLeft) HorizontalAlignment.TRAILING else HorizontalAlignment.LEADING
                    translateX: bind if (dockLeft) width else 0
                    cursor: Cursor.H_RESIZE
                    onMouseDragged: function(e:MouseEvent) {
                        resizing = true;
                        var draggedWidth = if (dockLeft) e.getScreenX().intValue() - screenBounds.x
                                else screenBounds.x + screenBounds.width - e.getScreenX().intValue();
                        width = if (draggedWidth < MIN_WIDTH) MIN_WIDTH else if (draggedWidth > MAX_WIDTH) MAX_WIDTH else draggedWidth;
                    }
                    onMouseReleased: function(e) {
                        for (instance in container.dockedWidgets) {
                            if (instance.widget.resizable) {
                                if (instance.widget.onResize != null) {
                                    instance.widget.onResize(instance.widget.stage.width, instance.widget.stage.height);
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
