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
import javafx.input.*;
import javafx.lang.DeferredTask;
import javafx.scene.*;
import javafx.scene.effect.*;
import javafx.scene.geometry.*;
import javafx.scene.layout.*;
import javafx.scene.paint.*;
import javax.swing.RootPaneContainer;

/**
 * @author Stephen Chin
 */
public class WidgetView extends Group, Constrained {
    public static attribute TOP_BORDER = 13; // todo - set this back to 3 when the flash floating toolbars are fixed
    public static attribute BOTTOM_BORDER = 7;
    
    public attribute container:WidgetContainer;
    public attribute instance:WidgetInstance;
    public attribute widget = bind instance.widget;
    
    public attribute resizing = false;
    public attribute dragging = false;
    public attribute docking = false;
    
    private attribute dockedParent:Group;
    private attribute initialX:Integer;
    private attribute initialY:Integer;
    private attribute initialScreenX:Integer;
    private attribute initialScreenY:Integer;
    
    private attribute scale:Number = bind calculateScale();
    
    private bound function calculateScale():Number {
        return if (not widget.resizable) {
            var widthScale = if (maxWidth == Constrained.UNBOUNDED) 1.0 else maxWidth / widget.stage.width;
            var heightScale = if (maxHeight == Constrained.UNBOUNDED) 1.0 else maxHeight / widget.stage.height;
            var scale = Math.min(widthScale, heightScale);
            return if (scale > 1) 1 else scale;
        } else {
            1.0;
        }
    }
    
    private attribute firstRollover = true;
        
    private attribute hasFocus:Boolean on replace {
        if (firstRollover) {
            firstRollover = false;
        } else {
            rolloverTimeline.start();
        }
    }
    
    private attribute flashHover = bind if (widget instanceof FlashWidget) then (widget as FlashWidget).hover else false on replace {
        updateFocus();
    }
    
    private attribute needsFocus:Boolean;
    
    // this is a workaround for the issue with toggle timelines that are stopped and started immediately triggering a full animation
    public function requestFocus(focus:Boolean):Void {
        needsFocus = focus;
        updateFocus();
    }
    
    private function updateFocus() {
        DeferredTask {
            action: function() {
                hasFocus = needsFocus or flashHover;
            }
        }
    }
    
    private attribute rolloverOpacity = 0.0;
    private attribute rolloverTimeline = Timeline {
        autoReverse: true, toggle: true
        keyFrames: KeyFrame {time: 500ms, values: rolloverOpacity => 1.0 tween Interpolator.EASEIN}
    }
    
    private function resize() {
        if (instance.widget.resizable) {
            if (maxWidth != Constrained.UNBOUNDED) {
                instance.widget.stage.width = maxWidth.intValue();
            }
            if (maxHeight != Constrained.UNBOUNDED) {
                instance.widget.stage.height = maxHeight.intValue();
            }
            if (instance.widget.aspectRatio != 0) {
                var currentRatio = (instance.widget.stage.width as Number) / instance.widget.stage.height;
                if (currentRatio > instance.widget.aspectRatio) {
                    instance.widget.stage.width = (instance.widget.aspectRatio * instance.widget.stage.height).intValue();                
                } else {
                    instance.widget.stage.height = (instance.widget.stage.width / instance.widget.aspectRatio).intValue();
                }
            }
        }
    }
    
    override attribute translateX on replace {
        updateFlashBounds();
    }
    
    override attribute translateY on replace {
        updateFlashBounds();
    }
    
    override attribute impl_layoutX on replace {
        updateFlashBounds();
    }
    
    override attribute impl_layoutY on replace {
        updateFlashBounds();
    }
    
    override attribute maxWidth on replace {
        resize();
        updateFlashBounds();
    }
    
    override attribute maxHeight on replace {
        resize();
        updateFlashBounds();
    }
    
    init {
        cache = true;
        content = [
            Rectangle { // Invisible Spacer
                height: bind widget.stage.height * scale + TOP_BORDER + BOTTOM_BORDER
                width: bind maxWidth
                fill: Color.rgb(0, 0, 0, 0.0)
            },
            Group { // Widget with DropShadow
                translateY: TOP_BORDER
                translateX: bind (maxWidth - widget.stage.width * scale) / 2
                content: [
                    Group { // Rear Slice
                        cache: true
                        content: Group { // Drop Shadow
                            effect: bind if (resizing or container.resizing) null else DropShadow {offsetX: 2, offsetY: 2, radius: Dock.DS_RADIUS}
                            content: Group { // Clip Group
                                content: bind widget.stage.content[0]
                                clip: Rectangle {width: bind widget.stage.width, height: bind widget.stage.height}
                                scaleX: bind scale, scaleY: bind scale
                            }
                        }
                    },
                    Group { // Front Slices
                        cache: true
                        content: bind widget.stage.content[1..]
                        clip: Rectangle {width: bind widget.stage.width, height: bind widget.stage.height}
                        scaleX: bind scale, scaleY: bind scale
                    },
                ]
            },
            WidgetToolbar {
                blocksMouse: true
                translateX: bind (maxWidth + widget.stage.width * scale) / 2
                opacity: bind rolloverOpacity
                instance: instance
                onMouseEntered: function(e) {requestFocus(true)}
                onMouseExited: function(e) {requestFocus(false)}
                onClose: function() {
                    removeFlash();
                    WidgetManager.getInstance().removeWidget(instance);
                }
            },
            Group { // Drag Bar
                blocksMouse: true
                translateY: bind widget.stage.height * scale + TOP_BORDER + BOTTOM_BORDER - 3
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
                        initialHeight = widget.stage.height * scale;
                        initialY = e.getStageY().intValue();
                    }
                }
                onMouseDragged: function(e:MouseEvent) {
                    if (resizing) {
                        widget.stage.height = (initialHeight + (e.getStageY().intValue() - initialY) / scale).intValue();
                        if (widget.stage.height < WidgetInstance.MIN_HEIGHT) {
                            widget.stage.height = WidgetInstance.MIN_HEIGHT;
                        }
                        if (widget.aspectRatio != 0) {
                            widget.stage.width = (widget.stage.height * widget.aspectRatio).intValue();
                            if (widget.stage.width > maxWidth) {
                                widget.stage.width = maxWidth.intValue();
                                widget.stage.height = (widget.stage.width / widget.aspectRatio).intValue();
                            }
                        }
                        updateFlashBounds();
                    }
                }
                onMouseReleased: function(e) {
                    if (resizing) {
                        if (widget.onResize != null) {
                            widget.onResize(widget.stage.width, widget.stage.height);
                        }
                        instance.saveWithoutNotification();
                        resizing = false;
                    }
                }
            }
        ];
        onMousePressed = function(e:MouseEvent):Void {
            if (not widget.dragAnywhere and e.getButton() == 1) {
                prepareDrag(e.getX(), e.getY(), e.getScreenX(), e.getScreenY());
            }
        };
        onMouseDragged = function(e:MouseEvent):Void {
            doDrag(e.getScreenX(), e.getScreenY());
        };
        onMouseReleased = function(e:MouseEvent):Void {
            if (not widget.dragAnywhere and e.getButton() == 1) {
                finishDrag(e.getScreenX(), e.getScreenY());
            }
        };
        addFlash();
    }
    
    public function prepareDrag(dragX:Integer, dragY:Integer, screenX:Integer, screenY:Integer) {
        dragging = true;
        initialScreenX = screenX;
        initialScreenY = screenY;
        for (container in WidgetContainer.containers) {
            container.prepareHover(instance, dragX, dragY);
        }
    }
    
    public function doDrag(screenX:Integer, screenY:Integer) {
        if (not docking and dragging) {
            var xPos;
            var yPos;
            var beginningFlashOffset = flashOffset;
            if (instance.docked) {
                container.dragging = true;
                hideFlash();
                var bounds = container.layout.getScreenBounds(this);
                xPos = (bounds.x + (bounds.width - widget.stage.width * scale) / 2 - WidgetFrame.BORDER).intValue();
                var toolbarHeight = if (instance.widget.configuration == null) WidgetFrame.NONRESIZABLE_TOOLBAR_HEIGHT else WidgetFrame.RESIZABLE_TOOLBAR_HEIGHT;
                yPos = bounds.y + TOP_BORDER - (WidgetFrame.BORDER + toolbarHeight);
                if (instance.frame == null) {
                    instance.frame = WidgetFrame {
                        instance: instance
                        x: xPos, y: yPos
                    }
                } else {
                    instance.frame.populateContents();
                }
                initialX = xPos;
                initialY = yPos;
                instance.docked = false;
            }
            var hoverOffset = [0, 0];
            for (container in WidgetContainer.containers) {
                var offset = container.hover(instance, screenX, screenY + flashOffset, not instance.docked);
                if (offset != [0, 0]) {
                    hoverOffset = offset;
                }
            }
            instance.frame.x = initialX + screenX - initialScreenX + hoverOffset[0];
            instance.frame.y = initialY + screenY - initialScreenY + hoverOffset[1] + beginningFlashOffset;
        }
    }
    
    public function finishDrag(screenX:Integer, screenY:Integer) {
        if (not docking and not instance.docked) {
            dragging = false;
            container.dragging = false;
            for (container in WidgetContainer.containers) {
                var targetBounds = container.finishHover(instance, screenX, screenY + flashOffset);
                if (targetBounds != null) {
                    docking = true;
                    instance.frame.dock(targetBounds.x + (targetBounds.width - widget.stage.width) / 2, targetBounds.y);
                } else {
                    // todo - don't call this block multiple times
                    if (instance.widget.onResize != null) {
                        instance.widget.onResize(instance.widget.stage.width, instance.widget.stage.height);
                    }
                    java.lang.System.out.println("adding flash...");
                    instance.frame.addFlash();
                    if (instance.widget.onUndock != null) {
                        instance.widget.onUndock();
                    }
                }
            }
            instance.saveWithoutNotification();
        }
    }
    
    private attribute flashOffset:Integer = 0;
    private attribute added = false;
    
    private function addFlash() {
        if (widget instanceof FlashWidget) {
            var flash = widget as FlashWidget;
            var layeredPane = (container.window as RootPaneContainer).getLayeredPane();
            if (flash.panel.getParent() != layeredPane) {
                layeredPane.add(flash.panel, new java.lang.Integer(1000));
            }
            instance.frame = WidgetFrame {
                instance: instance
                hidden: true
            }
            added = true;
            updateFlashBounds();
        }
    }
    
    private function removeFlash() {
        if (widget instanceof FlashWidget) {
            added = false;
            var flash = widget as FlashWidget;
            var layeredPane = (container.window as RootPaneContainer).getLayeredPane();
            layeredPane.remove(flash.panel);
        }
    }
    
    private function hideFlash() {
        if (widget instanceof FlashWidget) {
            added = false;
            var flash = widget as FlashWidget;
            var currentLocation = flash.panel.getLocation();
            flash.panel.setLocation(currentLocation.x, -widget.stage.height);
            flashOffset = currentLocation.y + widget.stage.height;
        }
    }
    
    private function updateFlashBounds() {
        if (widget instanceof FlashWidget and added) {
            var flash = widget as FlashWidget;
            var location = new Point(0, 0);
            impl_getSGNode().localToGlobal(location, location);
            flash.panel.setBounds(location.x, location.y + TOP_BORDER, widget.stage.width, widget.stage.height);
        }
    }
}
