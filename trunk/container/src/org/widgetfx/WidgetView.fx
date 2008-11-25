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
import java.awt.Point;
import java.lang.*;
import javafx.animation.*;
import javafx.geometry.*;
import javafx.lang.*;
import javafx.scene.*;
import javafx.scene.effect.*;
import javafx.scene.input.*;
import javafx.scene.shape.*;
import javafx.scene.layout.*;
import javafx.scene.paint.*;
import javafx.stage.*;
import javax.swing.JPanel;
import javax.swing.RootPaneContainer;

/**
 * @author Stephen Chin
 */
public var TOP_BORDER = 13;
public var BOTTOM_BORDER = 7;

public class WidgetView extends Group, Constrained, DragContainer {    
    public-init var container:WidgetContainer;
    
    var resizing = false;
    
    var dockedParent:Group;
    
    var scale:Number = bind calculateScale();
    
    bound function calculateScale():Number {
        return if (not widget.resizable) {
            var widthScale = if (maxWidth == Constrained.UNBOUNDED) 1.0 else maxWidth / widget.width;
            var heightScale = if (maxHeight == Constrained.UNBOUNDED) 1.0 else maxHeight / widget.height;
            var scale = Math.min(widthScale, heightScale);
            if (scale > 1) 1.0 else scale;
        } else {
            1.0;
        }
    }
    
    var toolbar:WidgetToolbar;
    
    public var widgetHover = false;

    var flashHover = bind if (widget instanceof FlashWidget) then (widget as FlashWidget).widgetHovering else false;
    
    var hovering = bind widgetHover or flashHover on replace {
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
    
    var rolloverOpacity = 0.0;
    var rolloverTimeline = Timeline {
        keyFrames: at (500ms) {rolloverOpacity => 1.0 tween Interpolator.EASEIN}
    }
    
    function resize() {
        if (instance.widget.resizable) {
            if (maxWidth != Constrained.UNBOUNDED) {
                instance.setWidth(maxWidth);
            }
            if (maxHeight != Constrained.UNBOUNDED) {
                instance.setHeight(maxHeight);
            }
            if (instance.widget.aspectRatio != 0) {
                var currentRatio = (instance.widget.width as Number) / instance.widget.height;
                if (currentRatio > instance.widget.aspectRatio) {
                    instance.setWidth(instance.widget.aspectRatio * instance.widget.height);                
                } else {
                    instance.setHeight(instance.widget.width / instance.widget.aspectRatio);
                }
            }
        }
    }
    
    override var translateX on replace {
        updateFlashBounds();
    }
    
    override var translateY on replace {
        updateFlashBounds();
    }
    
    override var impl_layoutX on replace {
        updateFlashBounds();
    }
    
    override var impl_layoutY on replace {
        updateFlashBounds();
    }
    
    override var maxWidth on replace {
        resize();
        updateFlashBounds();
    }
    
    override var maxHeight on replace {
        resize();
        updateFlashBounds();
    }
    
    function wrapContent(content:Node[]):Node[] {
        java.lang.System.out.println("wrapping content: {content[0]}, XXXXXXXXXXXXXXXXX {content[1..]}");
        return [
            Rectangle { // Invisible Spacer
                height: bind widget.height * scale + TOP_BORDER + BOTTOM_BORDER
                width: bind widget.width * scale
                fill: Color.BLUE
                //fill: Color.rgb(0, 0, 0, 0.0)
            },
            Group { // Rear Slice
                cache: true
                content: Group { // Drop Shadow
                    effect: bind if (resizing or container.resizing) null else DropShadow {offsetX: 2, offsetY: 2, radius: Dock.DS_RADIUS}
                    content: Group { // Clip Group
                        content: content[0]
                        clip: Rectangle {width: bind widget.width, height: bind widget.height}
                        scaleX: bind scale, scaleY: bind scale
                    }
                }
            },
            Group { // Front Slices
                cache: true
                content: content[1..]
                clip: Rectangle {width: bind widget.width, height: bind widget.height}
                scaleX: bind scale, scaleY: bind scale
            },
        ]
    }
    
    override var cache = true;
    
    init {
        content = [
            Rectangle { // Invisible Spacer
                height: bind widget.height * scale + TOP_BORDER + BOTTOM_BORDER
                width: bind maxWidth
                fill: Color.rgb(0, 0, 0, 0.0)
            },
            Group { // Widget with DropShadow
                translateY: TOP_BORDER
                translateX: bind (maxWidth - widget.width * scale) / 2
                cache: true
                content: Group { // Drop Shadow
                    effect: bind if (resizing or container.resizing) null else DropShadow {offsetX: 2, offsetY: 2, radius: Dock.DS_RADIUS}
                    content: Group { // Clip Group
                        content: widget
                        clip: Rectangle {width: bind widget.width, height: bind widget.height}
                        scaleX: bind scale, scaleY: bind scale
                    }
                }
            },
            toolbar = WidgetToolbar {
                blocksMouse: true
                translateX: bind (maxWidth + widget.width * scale) / 2 - toolbar.boundsInLocal.maxX
                opacity: bind rolloverOpacity
                instance: instance
                onClose: function() {
                    removeFlash();
                    WidgetManager.getInstance().removeWidget(instance);
                }
            },
            Group { // Drag Bar
                blocksMouse: true
                translateY: bind widget.height * scale + TOP_BORDER + BOTTOM_BORDER - 3
                content: [
                    Line {endX: bind maxWidth, stroke: Color.BLACK, strokeWidth: 1, opacity: bind container.rolloverOpacity / 4},
                    Line {endX: bind maxWidth, stroke: Color.BLACK, strokeWidth: 1, opacity: bind container.rolloverOpacity, translateY: 1},
                    Line {endX: bind maxWidth, stroke: Color.WHITE, strokeWidth: 1, opacity: bind container.rolloverOpacity / 3, translateY: 2}
                ]
                cursor: Cursor.V_RESIZE
                var initialHeight;
                var initialY;
                onMousePressed: function(e:MouseEvent) {
                    if (widget.resizable) {
                        resizing = true;
                        initialHeight = widget.height * scale;
                        initialY = e.sceneY.intValue();
                    }
                }
                onMouseDragged: function(e:MouseEvent) {
                    if (resizing) {
                        instance.setHeight(initialHeight + (e.sceneY.intValue() - initialY) / scale);
                        if (widget.height < WidgetInstance.MIN_HEIGHT) {
                            instance.setHeight(WidgetInstance.MIN_HEIGHT);
                        }
                        if (widget.aspectRatio != 0) {
                            instance.setWidth(widget.height * widget.aspectRatio);
                            if (widget.width > maxWidth) {
                                instance.setWidth(maxWidth);
                                instance.setHeight(widget.width / widget.aspectRatio);
                            }
                        }
                        updateFlashBounds();
                    }
                }
                onMouseReleased: function(e) {
                    if (resizing) {
                        if (widget.onResize != null) {
                            widget.onResize(widget.width, widget.height);
                        }
                        instance.saveWithoutNotification();
                        resizing = false;
                    }
                }
            }
        ];
        addFlash();
    };
    
    override var onMousePressed = function(e:MouseEvent):Void {
        if (e.button == MouseButton.PRIMARY) {
            prepareDrag(e.x, e.y, e.screenX, e.screenY);
        }
    }

    override var onMouseDragged = function(e:MouseEvent):Void {
        if (not docking) {
        	doDrag(e.screenX, e.screenY);
		}
    };
    
    override var onMouseReleased = function(e:MouseEvent):Void {
        if (e.button == MouseButton.PRIMARY) {
            finishDrag(e.screenX, e.screenY);
        }
    }
    
    override function doDrag(screenX:Integer, screenY:Integer) {
        if (not docking and dragging) {
            container.dragging = true;
            if (instance.docked) {
                flashPanel.setVisible(false);
                var bounds = container.layout.getScreenBounds(this);
                var xPos = (bounds.minX + (bounds.width - widget.width * scale) / 2 - WidgetFrame.BORDER).intValue();
                var toolbarHeight = if (instance.widget.configuration == null) WidgetFrame.NONRESIZABLE_TOOLBAR_HEIGHT else WidgetFrame.RESIZABLE_TOOLBAR_HEIGHT;
                var yPos = bounds.minY + TOP_BORDER - (WidgetFrame.BORDER + toolbarHeight);
                instance.frame = WidgetFrame {
                    instance: instance
                    x: xPos, y: yPos
                    style: if (WidgetFXConfiguration.TRANSPARENT and not (widget instanceof FlashWidget)) StageStyle.TRANSPARENT else StageStyle.UNDECORATED
                }
                if (widget instanceof FlashWidget) {
                    var flash = widget as FlashWidget;
                    flash.dragContainer = this;
            }
                instance.docked = false;
            }
            DragContainer.doDrag(screenX, screenY);
        }
    }
    
    override function dragComplete(targetBounds:Rectangle2D):Void {
        container.dragging = false;
        removeFlash();
        if (targetBounds != null) {
            docking = true;
                    instance.frame.dock(targetBounds.minX + (targetBounds.width - widget.width) / 2, targetBounds.minY);
        } else {
            // todo - don't call this block multiple times
            if (instance.widget.onResize != null) {
                        instance.widget.onResize(instance.widget.width, instance.widget.height);
            }
            if (widget instanceof FlashWidget) {
                var flash = widget as FlashWidget;
                flash.dragContainer = instance.frame;
            }
            if (instance.widget.onUndock != null) {
                instance.widget.onUndock();
            }
        }
    }
    
    var flashPanel:JPanel;
    
    function addFlash() {
        if (widget instanceof FlashWidget) {
            var flash = widget as FlashWidget;
            flashPanel = flash.createPlayer();
            var layeredPane = (container.window as RootPaneContainer).getLayeredPane();
            layeredPane.add(flashPanel, new java.lang.Integer(1000));
            updateFlashBounds();
            flash.dragContainer = this;
        }
    }
    
    function removeFlash() {
        if (flashPanel != null) {
            var layeredPane = (container.window as RootPaneContainer).getLayeredPane();
            layeredPane.remove(flashPanel);
            flashPanel = null;
        }
    }
    
    function updateFlashBounds() {
        if (flashPanel != null) {
            var location = localToScene(0, 0);
            flashPanel.setBounds(location.x, location.y + TOP_BORDER, widget.width, widget.height);
        }
    }
}
