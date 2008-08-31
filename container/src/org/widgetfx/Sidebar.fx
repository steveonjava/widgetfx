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
import java.awt.Point;
import java.awt.SystemTray;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseMotionAdapter;
import java.awt.event.ActionListener;
import java.awt.event.ActionEvent;
import java.awt.GraphicsEnvironment;
import java.awt.geom.Ellipse2D;
import java.awt.image.BufferedImage;
import java.util.Arrays;
import java.io.*;
import java.lang.System;

/**
 * @author Stephen Chin
 */
public class Sidebar extends BaseDialog {
    static attribute DEFAULT_WIDTH = 180;
    static attribute MIN_WIDTH = 120;
    static attribute MAX_WIDTH = 400;
    static attribute BORDER = 5;
    static attribute DS_RADIUS = 5;
    static attribute BG_OPACITY = 0.7;
    static attribute BUTTON_COLOR = Color.rgb(0xA0, 0xA0, 0xA0);
    static attribute BUTTON_BG_COLOR = Color.rgb(0, 0, 0, 0.1);
    
    private static attribute instance = Sidebar {}
    
    public static function getInstance() {
        return instance;
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
        }
    ]);
    
    private attribute mainMenu = createMainMenu();
    private attribute logo:Node;
    private attribute content:GapVBox;
    private attribute headerHeight = bind BORDER * 2 + logo.getHeight();
    private attribute dockedWidgets = bind WidgetManager.getInstance().widgets[w|w.docked];
    attribute widgetViews:Node[] = bind for (instance in dockedWidgets) createWidgetView(instance);
    
    private attribute currentGraphics:java.awt.GraphicsConfiguration;
    private attribute screenBounds = bind currentGraphics.getBounds() on replace {
        updateDockLocation();
    }
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
        updateDockLocation();
    };
    private attribute dockRight:Boolean on replace {
        dockLeft = not dockRight;
        updateDockLocation();
    };

    private attribute widthTrigger = bind width on replace {
        updateDockLocation();
    }

    private attribute alwaysOnTop:Boolean on replace {
        window.setAlwaysOnTop(alwaysOnTop);
    }
    
    attribute resizing:Boolean;
    attribute dragging:Boolean;
    
    private function updateDockLocation() {
        height = screenBounds.height;
        x = screenBounds.x + (if (dockLeft) 0 else screenBounds.width - width);
        y = screenBounds.y;
    }
    
    //private attribute backgroundImage : Image = Image {url:getClass().getResource("Inovis_SidebarBackground1.jpg").toString(), height: 1200};
    
    private attribute transparentBG = bind if (dockLeft) leftBG else rightBG;
    private attribute bgOpacity = BG_OPACITY;
    private attribute leftBG = bind LinearGradient {
        endY: 0
        stops: [
            Stop {offset: 0.0, color: Color.color(0, 0, 0, bgOpacity)},
            Stop {offset: 1.0, color: Color.color(0, 0, 0, 0)}
        ]
    }
    private attribute rightBG = bind LinearGradient {
        endY: 0
        stops: [
            Stop {offset: 0.0, color: Color.color(0, 0, 0, 0)},
            Stop {offset: 1.0, color: Color.color(0, 0, 0, bgOpacity)}
        ]
    }
    
    private attribute launchOnStartup:Boolean = true on replace {
        if (launchOnStartup) {
            InstallUtil.copyStartupFile();
        } else {
            InstallUtil.deleteStartupFile();
        }
    }
    
    init {
        title = "WidgetFX";
        visible = true;
        windowStyle = WindowStyle.TRANSPARENT;
        width = DEFAULT_WIDTH + BORDER * 2;
    }

    postinit {
        configuration.load();
        loadContent();
        createTrayIcon();
    }
    
    private function hideDock() {
        visible = false;
    }
    
    private function showDock() {
        visible = true;
        DeferredTask { // workaround for defect where dock moves to center on show
            action: function() {updateDockLocation();}
        }
        toFront();
    }
    
    private function createTrayIcon() {
        var tray:JXTrayIcon = new JXTrayIcon(createImage());
        tray.setJPopupMenu(mainMenu);
        tray.addActionListener(ActionListener {
                public function actionPerformed(e) {
                    showDock();
                    for (instance in WidgetManager.getInstance().widgets where instance.frame != null) {
                        instance.frame.toFront();
                    }
                }
        });
        try {
            SystemTray.getSystemTray().add(tray);
        } catch (e:AWTException) {
            e.printStackTrace();
        }
    }
    
    static function createImage():java.awt.Image {
        var i = new BufferedImage(32, 32, BufferedImage.TYPE_INT_ARGB);
        var g2 = i.getGraphics() as Graphics2D;
        g2.setColor(java.awt.Color.RED);
        g2.fill(new Ellipse2D.Float(0, 0, i.getWidth(), i.getHeight()));
        g2.dispose();
        return i;
    }
    
    public function addWidget():Void {
        org.widgetfx.ui.AddWidgetDialog {}.showDialog();
    }
    
    public function createMainMenu():JPopupMenu {
        var menu = Menu {
            items: [
                MenuItem {
                    text: "Add Widget..."
                    action: addWidget
                },
                CheckBoxMenuItem {
                    text: "Always on Top"
                    selected: bind alwaysOnTop with inverse;
                },
                CheckBoxMenuItem {
                    text: "Launch on Startup"
                    selected: bind launchOnStartup with inverse
                },
                Menu {
                    var group = ToggleGroup {}
                    text: "Dock Sidebar"
                    items: [
                        RadioButtonMenuItem {
                            text: "Left"
                            toggleGroup: group
                            selected: bind dockLeft with inverse
                        },
                        RadioButtonMenuItem {
                            text: "Right"
                            toggleGroup: group
                            selected: bind dockRight with inverse
                        }
                    ]

                },
                MenuItem {
                    text: bind if (visible) "Hide" else "Show"
                    action: function() {
                        if (visible) {
                            hideDock;
                        } else {
                            showDock();
                        }
                    }
                },
                MenuItem {
                    text: "Exit"
                    action: function() {
                        System.exit(0);
                    }
                }
            ]
        }
        // todo - replace with javafx Separator when one exists
        menu.getJMenu().insertSeparator(1);
        menu.getJMenu().insertSeparator(4);
        // todo - create a javafx PopupMenu directly when one exists
        return menu.getJMenu().getPopupMenu();
    }
    
    private attribute animateHover:Timeline;
    private attribute animateDocked:Boolean;
    private attribute saveUndockedWidth:Integer;
    private attribute saveUndockedHeight:Integer;
    
    public function setupHoverAnimation(instance:WidgetInstance) {
        if (animateHover == null) {
            saveUndockedWidth = instance.undockedWidth;
            saveUndockedHeight = instance.undockedHeight;
            var newWidth = if (instance.docked) instance.undockedWidth else instance.dockedWidth;
            var newHeight = if (instance.docked) instance.undockedHeight else instance.dockedHeight;
            if (newWidth > 0 or newHeight > 0) {
                animateHover = Timeline {
                    autoReverse: true, toggle: true
                    keyFrames: KeyFrame {
                        time: 300ms
                        values: [
                            if (newWidth > 0) {
                                instance.widget.stage.width => newWidth tween Interpolator.EASEBOTH
                            } else {
                                []
                            },
                            if (newHeight > 0) {
                                instance.widget.stage.height => newHeight tween Interpolator.EASEBOTH
                            } else {
                                []
                            }
                        ]
                    }
                }
            }
            animateDocked = instance.docked;
        }
    }
    
    public function hover(instance:WidgetInstance, screenX:Integer, screenY:Integer, animate:Boolean) {
        setupHoverAnimation(instance);
        if (screenX >= x and screenX < x + width and screenY >= y and screenY < y + height) {
            var index = widgetViews.size();
            var localY = screenY - y;
            for (view in widgetViews) {
                var viewY = view.getBoundsY() + headerHeight;
                var viewHeight = view.getBoundsHeight();
                if (localY < viewY + viewHeight / 2) {
                    index = indexof view;
                    break;
                }
            }
            var dockedHeight = if (instance.dockedHeight == 0) instance.widget.stage.height else instance.dockedHeight;
            content.setGap(index, dockedHeight + DS_RADIUS * 2 + 2, animate);
            if (animateHover != null and not animateDocked) {
                animateDocked = true;
                animateHover.start();
            }
        } else {
            content.clearGap(animate);
            if (animateHover != null and animateDocked) {
                animateDocked = false;
                animateHover.start();
            }
        }
    }
    
    public function finishHover(instance:WidgetInstance, screenX:Integer, screenY:Integer):java.awt.Rectangle {
        if (screenX >= x and screenX < x + width and screenY >= y and screenY < y + height) {
            animateHover.stop();
            animateHover = null;
            instance.undockedWidth = saveUndockedWidth;
            instance.undockedHeight = saveUndockedHeight;
            return new java.awt.Rectangle(
                x + (width - instance.widget.stage.width) / 2 - BORDER,
                y + content.getGapLocation() + headerHeight,
                instance.widget.stage.width,
                instance.widget.stage.height
            );
        } else {
            animateHover = null;
            return null;        
        }
    }
    
    public function dock(instance:WidgetInstance) {
        delete instance from WidgetManager.getInstance().widgets;
        instance.docked = true;
        if (content.getGapIndex() >= dockedWidgets.size()) {
            insert instance into WidgetManager.getInstance().widgets;
        } else {
            var index = Sequences.indexOf(WidgetManager.getInstance().widgets, dockedWidgets[content.getGapIndex()]);
            insert instance before WidgetManager.getInstance().widgets[index];
        }
        content.clearGap(false);
    }
    
    private function createWidgetView(instance:WidgetInstance):WidgetView {
        updateWidth(instance, false);
        return WidgetView {
            sidebar: this
            instance: instance
        }
    }
    
    private function updateWidth(instance:WidgetInstance, notifyResize:Boolean):Void {
        if (instance.widget.resizable) {
            instance.widget.stage.width = width - BORDER * 2;
            if (instance.widget.aspectRatio != 0) {
                instance.widget.stage.height = (instance.widget.stage.width / instance.widget.aspectRatio).intValue();
            }
            if (notifyResize) {
                if (instance.widget.onResize != null) {
                    instance.widget.onResize(instance.widget.stage.width, instance.widget.stage.height);
                }
                instance.saveWithoutNotification();
            }
        }
    }
    
    attribute rolloverOpacity = 0.01;
    attribute rolloverTimeline = Timeline {
        autoReverse: true, toggle: true
        keyFrames: KeyFrame {time: 1s, values: [rolloverOpacity => BG_OPACITY tween Interpolator.EASEBOTH, bgOpacity => BG_OPACITY tween Interpolator.EASEBOTH]}
    }
    
    private function loadContent():Void {
        closeAction = function() {System.exit(0);};
        logo = HBox { // Logo Text
            translateX: BORDER, translateY: BORDER
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
        }
        var addWidgetButton = Group {
            var color = BUTTON_COLOR;
            translateY: 7
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
                mainMenu.show(window, e.getStageX(), e.getStageY());
            }
        }
        var hideButton = Group {
            var color = BUTTON_COLOR;
            translateY: 7
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
        content = GapVBox {
            translateY: bind headerHeight
            content: bind widgetViews
        }
        stage = Stage {
            content: [
//                ImageView {image:backgroundImage, opacity: .9},      
                logo,
                menus,
                content,
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
                        for (instance in dockedWidgets) {
                            updateWidth(instance, false);
                        }
                    }
                    onMouseReleased: function(e) {
                        for (instance in dockedWidgets) {
                            updateWidth(instance, true);
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
        if (not dragging and not resizing) {
            if (not screenBounds.contains(location)) {
                for (gd in Arrays.asList(java.awt.GraphicsEnvironment.getLocalGraphicsEnvironment().getScreenDevices())) {
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
