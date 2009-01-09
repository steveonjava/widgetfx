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

import org.widgetfx.*;
import org.widgetfx.config.*;
import org.widgetfx.layout.*;
import org.widgetfx.toolbar.*;
import org.widgetfx.widgets.*;
import org.jfxtras.scene.*;
import org.jfxtras.stage.*;
import java.awt.event.*;
import javafx.animation.*;
import javafx.ext.swing.*;
import javafx.geometry.*;
import javafx.lang.*;
import javafx.scene.*;
import javafx.scene.effect.*;
import javafx.scene.input.*;
import javafx.scene.input.MouseEvent;
import javafx.scene.paint.*;
import javafx.scene.shape.*;
import javafx.scene.transform.*;
import javafx.stage.*;
import javax.swing.*;
import javax.swing.SwingUtilities;

/**
 * @author Stephen Chin
 */
public var BORDER = 5;
public var RESIZABLE_TOOLBAR_HEIGHT = 18;
public var NONRESIZABLE_TOOLBAR_HEIGHT = RESIZABLE_TOOLBAR_HEIGHT - BORDER;
public var DS_RADIUS = 5;

public class WidgetFrame extends JFXDialog, DragContainer {
    var toolbarHeight = bind if (instance.widget.configuration == null) NONRESIZABLE_TOOLBAR_HEIGHT else RESIZABLE_TOOLBAR_HEIGHT;
    
    public-init var hidden = false;
    
    var isFlash = bind widget instanceof FlashWidget;
    
    var useOpacity = bind WidgetFXConfiguration.TRANSPARENT and isFlash and WidgetFXConfiguration.IS_VISTA;
    
    var sliderEnabled = bind style == StageStyle.TRANSPARENT or useOpacity;
    
    var xSync = bind x on replace {
        instance.undockedX = x;
    }
    
    var ySync = bind y on replace {
        instance.undockedY = y;
    }
    
    var widgetWidth = bind widget.width + BORDER * 2 + 1 on replace {
        width = widgetWidth;
        updateFlashBounds();
    }
    
    var boxHeight = bind widget.height + BORDER * 2 + 1;
    
    var widgetHeight = bind boxHeight + toolbarHeight on replace {
        height = widgetHeight;
        updateFlashBounds();
    }
    
    override var independentFocus = true;
    
    public var resizing:Boolean;
    var changingOpacity:Boolean;
    
    var initialWidth:Number;
    var initialHeight:Number;
        
    var saveInitialPos = function(e:MouseEvent):Void {
        initialX = x;
        initialY = y;
        initialWidth = widget.width;
        initialHeight = widget.height;
        initialScreenX = e.sceneX + x;
        initialScreenY = e.sceneY + y;
    }
    
    function mouseDelta(deltaFunction:function(a:Integer, b:Integer):Void):function(c:MouseEvent):Void {
        return function (e:MouseEvent):Void {
            var xDelta = e.screenX - initialScreenX;
            var yDelta = e.screenY - initialScreenY;
            deltaFunction(xDelta, yDelta);
        }
    }
    
    var startResizing = function(e:MouseEvent):Void {
        resizing = true;
        saveInitialPos(e);
    }
    
    var doneResizing = function(e:MouseEvent):Void {
        if (widget.onResize != null) {
            widget.onResize(widget.width, widget.height);
        }
        instance.saveWithoutNotification();
        resizing = false;
    }
    
    override var title = instance.title;
    
    public function dock(container:WidgetContainer, dockX:Integer, dockY:Integer):Void {
        docking = true;
        Timeline {
            keyFrames: KeyFrame {time: 300ms,
                values: [
                    x => dockX - BORDER tween Interpolator.EASEIN,
                    y => dockY - BORDER - toolbarHeight tween Interpolator.EASEIN
                ],
                action: function() {
                    container.dockAfterHover(instance);
                    if (instance.widget.onResize != null) {
                        instance.widget.onResize(widget.width, widget.height);
                    }
                }
            }
        }.play();
    }
    
    function resize(widthDelta:Number, heightDelta:Number, updateX:Boolean, updateY:Boolean, widthOnly:Boolean, heightOnly:Boolean) {
        var newWidth = if (initialWidth + widthDelta < WidgetInstance.MIN_WIDTH) then WidgetInstance.MIN_WIDTH else initialWidth + widthDelta;
        var newHeight = if (initialHeight + heightDelta < WidgetInstance.MIN_HEIGHT) then WidgetInstance.MIN_HEIGHT else initialHeight + heightDelta;
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
        instance.setWidth(newWidth);
        instance.setHeight(newHeight);
    }
    
    override var opacity = bind (if (hoverContainer) 0.4 else 1) * (if (useOpacity) instance.opacity / 100.0 else 1.0);

    var rolloverOpacity = 0.0;
    var rolloverTimeline = Timeline {
        keyFrames: [
            at (0s) {rolloverOpacity => 0.0}
            at (500ms) {rolloverOpacity => 1.0 tween Interpolator.EASEIN}
        ]
    }
    
    var sceneContents:Group;
    
    var widgetHover = false;
	
    var flashHover = bind if (isFlash) then (widget as FlashWidget).widgetHovering else false;
    
    var hovering = bind widgetHover or flashHover or dragging or resizing or changingOpacity on replace {
        FX.deferAction(
            function():Void {
                var newRate = if (hovering) 1 else -1;
                if (rolloverTimeline.rate != newRate) {
                    rolloverTimeline.rate = newRate;
                    rolloverTimeline.play();
                }
            }
        )
    }
    
    init {
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
                if (e.button == MouseButton.PRIMARY and not resizing) {
                    prepareDrag(e.x, e.y, e.screenX, e.screenY);
                }
            }
            onMouseDragged: function(e:MouseEvent) {
                doDrag(e.screenX, e.screenY);
            }
            onMouseReleased: function(e:MouseEvent) {
                if (e.button == MouseButton.PRIMARY) {
                    finishDrag(e.screenX, e.screenY);
                }
            }
        }
        var slider = SwingSlider {
            minimum: 20
            maximum: 100
            value: bind instance.opacity with inverse
            width: bind width * 2 / 5
        }
        scene = Scene {
            stylesheets: bind WidgetManager.getInstance().stylesheets
            content: sceneContents = Group {
                var toolbar:WidgetToolbar;
                content: [
                    dragRect,
                    CacheSafeGroup { // Widget
                        translateX: BORDER, translateY: BORDER + toolbarHeight
                        cache: true
                        content: Group { // Alert
                            effect: bind if (widget.alert) DropShadow {color: Color.RED, radius: 12} else null
                            content: Group { // Drop Shadow
                                effect: bind if (resizing or animating) null else DropShadow {offsetX: 2, offsetY: 2, radius: DS_RADIUS}
                                content: Group { // Clip Group
                                    content: widget
                                    clip: Rectangle {width: bind widget.width, height: bind widget.height, smooth: false}
                                }
                            }
                        }
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
                                Group { // Slider
                                    translateX: 1
                                    translateY: -2
                                    content: slider
                                }
                            ]
                            opacity: bind rolloverOpacity
                        }
                    } else {
                        []
                    },
                    toolbar = WidgetToolbar {
                        translateX: bind width - toolbar.boundsInLocal.maxX
                        opacity: bind rolloverOpacity
                        instance: instance
                        onClose: function() {
                            WidgetManager.getInstance().removeWidget(instance);
                            close();
        		            WidgetEventQueue.getInstance().removeInterceptor(dialog);
                        }
                    }
                ]
            }
            fill: null;
        }
        
        WidgetEventQueue.getInstance().registerInterceptor(dialog, EventInterceptor {
            override function shouldIntercept(event):Boolean {
                if (event.getID() == java.awt.event.MouseEvent.MOUSE_ENTERED) {
                    widgetHover = true;
                } else if (event.getID() == java.awt.event.MouseEvent.MOUSE_EXITED) {
                    widgetHover = false;
                }
                return false;
            }
        });
        slider.getJSlider().addMouseListener(MouseAdapter {
            override function mousePressed(e) {
                changingOpacity = true;
            }
            override function mouseReleased(e) {
                changingOpacity = false;
                instance.saveWithoutNotification();
            }
        });
        addFlash();
        visible = true;
    }

    override function dragComplete(dragListener:WidgetDragListener, targetBounds:Rectangle2D):Void {
        if (targetBounds != null) {
            dock(dragListener as WidgetContainer, targetBounds.minX + (targetBounds.width - widget.width) / 2, targetBounds.minY);
        }
    }
    
    var flashPanel:JPanel;
    
    public function addFlash() {
        if (isFlash) {
            var flash = widget as FlashWidget;
            flashPanel = flash.createPlayer();
            var layeredPane = (dialog as RootPaneContainer).getLayeredPane();
            layeredPane.add(flashPanel, new java.lang.Integer(1000));
            updateFlashBounds();
            flash.dragContainer = this;
        }
    }
    
    function updateFlashBounds() {
        if (flashPanel != null) {
            var layeredPane = (dialog as RootPaneContainer).getLayeredPane();
            if (flashPanel.getParent() == layeredPane) {
                flashPanel.setBounds(BORDER, BORDER + toolbarHeight, widget.width, widget.height);
            }
        }
    }
}
