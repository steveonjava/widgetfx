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

import org.widgetfx.toolbar.WidgetToolbar;
import org.widgetfx.ui.*;
import javafx.application.WindowStyle;
import javafx.application.Stage;
import javafx.scene.Group;
import javafx.scene.Cursor;
import javafx.scene.paint.Color;
import javafx.animation.Timeline;
import javafx.animation.KeyFrame;
import javafx.animation.Interpolator;
import javafx.ext.swing.ComponentView;
import javafx.ext.swing.Slider;
import javafx.input.MouseEvent;
import javafx.lang.DeferredTask;
import javafx.scene.HorizontalAlignment;
import javafx.scene.effect.DropShadow;
import javafx.scene.effect.Glow;
import javafx.scene.geometry.Circle;
import javafx.scene.geometry.DelegateShape;
import javafx.scene.geometry.Line;
import javafx.scene.geometry.Rectangle;
import javafx.scene.geometry.ShapeSubtract;
import javafx.scene.paint.RadialGradient;
import javafx.scene.paint.Stop;
import javafx.scene.transform.Rotate;
import javafx.scene.transform.Scale;
import java.awt.Component;
import java.awt.event.MouseAdapter;
import javax.swing.event.MouseInputAdapter;
import javax.swing.RootPaneContainer;
import javax.swing.SwingUtilities;

/**
 * @author Stephen Chin
 */
public class WidgetFrame extends BaseDialog, DragContainer {
    public static attribute BORDER = 5;
    public static attribute RESIZABLE_TOOLBAR_HEIGHT = 18;
    public static attribute NONRESIZABLE_TOOLBAR_HEIGHT = RESIZABLE_TOOLBAR_HEIGHT - BORDER;
    public static attribute DS_RADIUS = 5;
    
    private attribute toolbarHeight = bind if (instance.widget.configuration == null) NONRESIZABLE_TOOLBAR_HEIGHT else RESIZABLE_TOOLBAR_HEIGHT;
    
    public attribute hidden = false;
    
    private attribute widget = bind instance.widget;
    
    private attribute isFlash = bind widget instanceof FlashWidget;
    
    private attribute supportsTransparency = bind WidgetFXConfiguration.TRANSPARENT and not isFlash;
    
    private attribute useOpacity = bind WidgetFXConfiguration.TRANSPARENT and isFlash and WidgetFXConfiguration.IS_VISTA;
    
    private attribute sliderEnabled = bind supportsTransparency or useOpacity;
    
    private attribute xSync = bind x on replace {
        instance.undockedX = x;
    }
    
    private attribute ySync = bind y on replace {
        instance.undockedY = y;
    }
    
    private attribute widgetWidth = bind widget.stage.width + BORDER * 2 + 1 on replace {
        width = widgetWidth;
        updateFlashBounds();
    }
    
    private attribute boxHeight = bind widget.stage.height + BORDER * 2 + 1;
    
    private attribute widgetHeight = bind boxHeight + toolbarHeight on replace {
        height = widgetHeight;
        updateFlashBounds();
    }

    public attribute animating:Boolean on replace {
        updateFocus();
    }
    public attribute resizing:Boolean on replace {
        updateFocus();
    }
    override attribute dragging on replace {
        updateFocus();
    }
    private attribute changingOpacity:Boolean on replace {
        updateFocus();
    }
    
    private attribute initialWidth:Integer;
    private attribute initialHeight:Integer;
        
    private attribute saveInitialPos = function(screenX:Integer, screenY:Integer):Void {
        initialX = x;
        initialY = y;
        initialWidth = widget.stage.width;
        initialHeight = widget.stage.height;
        initialScreenX = screenX;
        initialScreenY = screenY;
    }
    
    private function mouseDelta(deltaFunction:function(a:Integer, b:Integer):Void):function(c:MouseEvent):Void {
        return function (e:MouseEvent):Void {
            var xDelta = e.getScreenX() - initialScreenX;
            var yDelta = e.getScreenY() - initialScreenY;
            deltaFunction(xDelta, yDelta);
        }
    }
    
    private attribute startResizing = function(e:MouseEvent):Void {
        resizing = true;
        saveInitialPos(e.getStageX().intValue() + x, e.getStageY().intValue() + y);
    }
    
    private attribute doneResizing = function(e:MouseEvent):Void {
        if (widget.onResize != null) {
            widget.onResize(widget.stage.width, widget.stage.height);
        }
        instance.saveWithoutNotification();
        resizing = false;
    }
    
    init {
        windowStyle = if (supportsTransparency) WindowStyle.TRANSPARENT else WindowStyle.UNDECORATED;
        title = instance.title;
    }
    
    public function dock(dockX:Integer, dockY:Integer):Void {
        docking = true;
        Timeline {
            keyFrames: KeyFrame {time: 300ms,
                values: [
                    x => dockX - BORDER tween Interpolator.EASEIN,
                    y => dockY - BORDER - toolbarHeight tween Interpolator.EASEIN
                ],
                action: function() {
                    for (container in WidgetContainer.containers) {
                        container.dockAfterHover(instance);
                    }
                    if (instance.widget.onResize != null) {
                        instance.widget.onResize(widget.stage.width, widget.stage.height);
                    }
                }
            }
        }.start();
    }
    
    /**
     * WidgetFrame close hook that has a default implementation to remove the widget
     * and close this Frame.
     * This can be overriden to provide custom behavior.
     */
    public attribute onClose = function(frame:WidgetFrame) {
        WidgetManager.getInstance().removeWidget(instance);
        frame.close();
        WidgetEventQueue.getInstance().removeInterceptor(window);
    }
    
    private function resize(widthDelta:Integer, heightDelta:Integer, updateX:Boolean, updateY:Boolean, widthOnly:Boolean, heightOnly:Boolean) {
        if (initialWidth + widthDelta < WidgetInstance.MIN_WIDTH) {
            widthDelta = WidgetInstance.MIN_WIDTH - initialWidth;
        }
        if (initialHeight + heightDelta < WidgetInstance.MIN_HEIGHT) {
            heightDelta = WidgetInstance.MIN_HEIGHT - initialHeight;
        }
        var newWidth = initialWidth + widthDelta;
        var newHeight = initialHeight + heightDelta;
        if (widget.aspectRatio != 0) {
            var aspectHeight = (newWidth / widget.aspectRatio).intValue();
            var aspectWidth = (newHeight * widget.aspectRatio).intValue();
            newWidth = if (not widthOnly and (heightOnly or aspectWidth < newWidth)) aspectWidth else newWidth;
            newHeight = if (not heightOnly and (widthOnly or aspectHeight < newHeight)) aspectHeight else newHeight;
        }
        if (updateX) {
            x = initialX + initialWidth - newWidth;
        }
        if (updateY) {
            y = initialY + initialHeight - newHeight;
        }
        widget.stage.width = newWidth;
        widget.stage.height = newHeight;
    }
    
    override attribute opacity = bind if (useOpacity) instance.opacity / 100.0 else 1.0;
    
    private attribute rolloverOpacity = 0.0;
    private attribute rolloverTimeline = Timeline {
        autoReverse: true, toggle: true
        keyFrames: KeyFrame {time: 500ms, values: rolloverOpacity => 1.0 tween Interpolator.EASEIN}
    }
    
    private attribute firstRollover = true;
        
    private attribute hasFocus:Boolean on replace {
        if (firstRollover) {
            firstRollover = false;
        } else {
            rolloverTimeline.start();
        }
    }
    
    private attribute flashHover = bind if (isFlash) then (widget as FlashWidget).hover else false on replace {
        updateFocus();
    }
    
    private attribute needsFocus:Boolean;
    
    // this is a workaround for the issue with toggle timelines that are stopped and started immediately triggering a full animation
    private function requestFocus(focus:Boolean):Void {
        needsFocus = focus;
        updateFocus();
    }
    
    private function updateFocus():Void {
        DeferredTask {
            action: function() {
                hasFocus = needsFocus or dragging or resizing or changingOpacity or animating or flashHover;
            }
        }
    }
    
    postinit {
        var dragRect:Group = Group {
            var backgroundColor = Color.rgb(0xF5, 0xF5, 0xF5, 0.6);
            translateY: toolbarHeight,
            content: [
                Rectangle { // background
                    translateX: BORDER, translateY: BORDER
                    width: bind width - BORDER * 2, height: bind boxHeight - BORDER * 2
                    fill: backgroundColor
                    opacity: bind (instance.opacity as Number) / 100
                },
                if (instance.widget.resizable) then [
                    Rectangle { // NW resize corner
                        width: BORDER, height: BORDER
                        stroke: null, fill: backgroundColor
                        cursor: Cursor.NW_RESIZE
                        blocksMouse: true
                        onMousePressed: startResizing
                        onMouseDragged: mouseDelta(function(xDelta:Integer, yDelta:Integer):Void {
                            resize(-xDelta, -yDelta, true, true, false, false);
                        })
                        onMouseReleased: doneResizing
                    },
                    Rectangle { // N resize corner
                        translateX: BORDER, width: bind width - BORDER * 2, height: BORDER
                        stroke: null, fill: backgroundColor
                        cursor: Cursor.N_RESIZE
                        blocksMouse: true
                        onMousePressed: startResizing
                        onMouseDragged: mouseDelta(function(xDelta:Integer, yDelta:Integer):Void {
                            resize(0, -yDelta, false, true, false, true);
                        })
                        onMouseReleased: doneResizing
                    },
                    Rectangle { // NE resize corner
                        translateX: bind width - BORDER, width: BORDER, height: BORDER
                        stroke: null, fill: backgroundColor
                        cursor: Cursor.NE_RESIZE
                        blocksMouse: true
                        onMousePressed: startResizing
                        onMouseDragged: mouseDelta(function(xDelta:Integer, yDelta:Integer):Void {
                            resize(xDelta, -yDelta, false, true, false, false);
                        })
                        onMouseReleased: doneResizing
                    },
                    Rectangle { // E resize corner
                        translateX: bind width - BORDER, translateY: BORDER
                        width: BORDER, height: bind boxHeight - BORDER * 2
                        stroke: null, fill: backgroundColor
                        cursor: Cursor.E_RESIZE
                        blocksMouse: true
                        onMousePressed: startResizing
                        onMouseDragged: mouseDelta(function(xDelta:Integer, yDelta:Integer):Void {
                            resize(xDelta, 0, false, false, true, false);
                        })
                        onMouseReleased: doneResizing
                    },
                    Rectangle { // SE resize corner
                        translateX: bind width - BORDER, translateY: bind boxHeight - BORDER
                        width: BORDER, height: BORDER
                        stroke: null, fill: backgroundColor
                        cursor: Cursor.SE_RESIZE
                        blocksMouse: true
                        onMousePressed: startResizing
                        onMouseDragged: mouseDelta(function(xDelta:Integer, yDelta:Integer):Void {
                            resize(xDelta, yDelta, false, false, false, false);
                        })
                        onMouseReleased: doneResizing
                    },
                    Rectangle { // S resize corner
                        translateX: BORDER, translateY: bind boxHeight - BORDER
                        width: bind width - BORDER * 2, height: BORDER
                        stroke: null, fill: backgroundColor
                        cursor: Cursor.S_RESIZE
                        blocksMouse: true
                        onMousePressed: startResizing
                        onMouseDragged: mouseDelta(function(xDelta:Integer, yDelta:Integer):Void {
                            resize(0, yDelta, false, false, false, true);
                        })
                        onMouseReleased: doneResizing
                    },
                    Rectangle { // SW resize corner
                        translateY: bind boxHeight - BORDER, width: BORDER, height: BORDER
                        stroke: null, fill: backgroundColor
                        cursor: Cursor.SW_RESIZE
                        blocksMouse: true
                        onMousePressed: startResizing
                        onMouseDragged: mouseDelta(function(xDelta:Integer, yDelta:Integer):Void {
                            resize(-xDelta, yDelta, true, false, false, false);
                        })
                        onMouseReleased: doneResizing
                    },
                    Rectangle { // W resize corner
                        translateY: BORDER, width: BORDER, height: bind boxHeight - BORDER * 2
                        stroke: null, fill: backgroundColor
                        cursor: Cursor.W_RESIZE
                        blocksMouse: true
                        onMousePressed: startResizing
                        onMouseDragged: mouseDelta(function(xDelta:Integer, yDelta:Integer):Void {
                            resize(-xDelta, 0, true, false, true, false);
                        })
                        onMouseReleased: doneResizing
                    }
                ] else [],
                Rectangle { // outer border
                    width: bind width - 1, height: bind boxHeight - 1
                    stroke: Color.BLACK
                },
                Rectangle { // inner border
                    translateX: 1, translateY: 1
                    width: bind width - 3, height: bind boxHeight - 3
                    stroke: Color.WHITESMOKE
                }
            ]
            opacity: bind if (widget.resizable) rolloverOpacity * 0.8 else 0.0;
            onMousePressed: function(e:MouseEvent) {
                if (e.getButton() == 1) {
                    prepareDrag(e.getX(), e.getY(), e.getScreenX(), e.getScreenY());
                }
            }
            onMouseDragged: function(e:MouseEvent) {
                doDrag(e.getScreenX(), e.getScreenY());
            }
            onMouseReleased: function(e:MouseEvent) {
                if (e.getButton() == 1) {
                    finishDrag(e.getScreenX(), e.getScreenY());
                }
            }
        }
        var slider = Slider {
            minimum: 20
            maximum: 99 // todo - hack to prevent swing component defect -- needs further investigation
            value: bind instance.opacity with inverse
            preferredSize: bind [width * 2 / 5, 16]
        }
        stage = Stage {
            content: [
                dragRect,
                Group { // Widget with DropShadow
                    translateX: BORDER, translateY: BORDER + toolbarHeight
                    content: [
                        Group { // Rear Slice
                            cache: true
                            content: Group { // Drop Shadow
                                effect: bind if (resizing or animating) null else DropShadow {offsetX: 2, offsetY: 2, radius: DS_RADIUS}
                                content: Group { // Clip Group
                                    content: bind widget.stage.content[0]
                                    clip: Rectangle {width: bind widget.stage.width, height: bind widget.stage.height}
                                }
                            }
                        },
                        Group { // Front Slices
                            cache: true
                            content: bind widget.stage.content[1..]
                            clip: Rectangle {width: bind widget.stage.width, height: bind widget.stage.height}
                        },
                    ]
                    opacity: bind (instance.opacity as Number) / 100
                },
                if (sliderEnabled) {
                    Group { // Transparency Slider
                        content: [
                            Rectangle { // Border
                                width: bind width * 2 / 5 + 2
                                height: 16
                                arcWidth: 16
                                arcHeight: 16
                                stroke: Color.BLACK
                            },
                            Rectangle { // Background
                                translateX: 1
                                translateY: 1
                                width: bind width * 2 / 5
                                height: 14
                                arcWidth: 14
                                arcHeight: 14
                                stroke: Color.WHITE
                                fill: WidgetToolbar.BACKGROUND
                                opacity: 0.7
                            },
                            ComponentView { // Slider
                                translateX: 1
                                component: slider
                            }
                        ]
                        opacity: bind rolloverOpacity
                    }
                } else {
                    []
                },
                WidgetToolbar {
                    translateX: bind width
                    opacity: bind rolloverOpacity
                    instance: instance
                    onClose: function() {
                        onClose(this);
                    }
                }
            ]
            fill: null
        }
        WidgetEventQueue.getInstance().registerInterceptor(window, EventInterceptor {
            public function shouldIntercept(event):Boolean {
                if (event.getID() == java.awt.event.MouseEvent.MOUSE_ENTERED) {
                    requestFocus(true);
                } else if (event.getID() == java.awt.event.MouseEvent.MOUSE_EXITED) {
                    requestFocus(false);
                }
                return false;
            }
        });
        slider.getJSlider().addMouseListener(MouseAdapter {
            public function mousePressed(e) {
                changingOpacity = true;
            }
            public function mouseReleased(e) {
                changingOpacity = false;
                instance.saveWithoutNotification();
            }
        });
        addFlash();
        visible = true;
    }
    
    public function prepareDrag(dragX:Integer, dragY:Integer, screenX:Integer, screenY:Integer) {
        dragging = true;
        saveInitialPos(screenX, screenY);
        for (container in WidgetContainer.containers) {
            container.prepareHover(instance, dragX, dragY);
        }
    }
    
    public function doDrag(screenX:Integer, screenY:Integer) {
        if (not docking and dragging) {
            var hoverOffset = [0, 0];
            for (container in WidgetContainer.containers) {
                var offset = container.hover(instance, screenX, screenY, true);
                if (offset != [0, 0]) {
                    hoverOffset = offset;
                }
            }
            x = initialX + screenX - initialScreenX + hoverOffset[0];
            y = initialY + screenY - initialScreenY + hoverOffset[1];
        }
    }
    
    protected function dragComplete(targetBounds:java.awt.Rectangle):Void {
        if (targetBounds != null) {
            dock(targetBounds.x + (targetBounds.width - widget.stage.width) / 2, targetBounds.y);
        }
    }
    
    private attribute added = false;
    
    public function addFlash() {
        if (isFlash) {
            var flash = widget as FlashWidget;
            var layeredPane = (window as RootPaneContainer).getLayeredPane();
            layeredPane.add(flash.panel, new java.lang.Integer(1000));
            added = true;
            updateFlashBounds();
            flash.dragContainer = this;
        }
    }
    
    private function updateFlashBounds() {
        if (isFlash and added) {
            var flash = widget as FlashWidget;
            var layeredPane = (window as RootPaneContainer).getLayeredPane();
            if (flash.panel.getParent() == layeredPane) {
                flash.panel.setBounds(BORDER, BORDER + toolbarHeight, widget.stage.width, widget.stage.height);
            }
        }
    }
}
