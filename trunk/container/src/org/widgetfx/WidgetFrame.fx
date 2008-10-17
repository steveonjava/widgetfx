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

import org.widgetfx.toolbar.*;
import org.widgetfx.ui.*;
import java.awt.event.*;
import javafx.animation.*;
import javafx.ext.swing.*;
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

/**
 * @author Stephen Chin
 */
public var BORDER = 5;
public var RESIZABLE_TOOLBAR_HEIGHT = 18;
public var NONRESIZABLE_TOOLBAR_HEIGHT = RESIZABLE_TOOLBAR_HEIGHT - BORDER;
public var DS_RADIUS = 5;

// todo - figure out a way to create a dialog out of a stage
public class WidgetFrame extends Stage {
    var toolbarHeight = bind if (instance.widget.configuration == null) NONRESIZABLE_TOOLBAR_HEIGHT else RESIZABLE_TOOLBAR_HEIGHT;
    
    public-init var instance:WidgetInstance;
    
    var boxHeight:Number;
    
    var widget = bind instance.widget on replace {
        width = widget.width + BORDER * 2 + 1;
        boxHeight = widget.height + BORDER * 2 + 1;
        height = boxHeight + toolbarHeight;
    }
    
    var xSync = bind x on replace {
        instance.undockedX = x;
    }
    
    var ySync = bind y on replace {
        instance.undockedY = y;
    }

    public var resizing:Boolean on replace {
        updateFocus();
    }
    var dragging:Boolean on replace {
        updateFocus();
    }
    var changingOpacity:Boolean on replace {
        updateFocus();
    }
    var docking:Boolean;
    
    var initialX:Number;
    var initialY:Number;
    var initialWidth:Number;
    var initialHeight:Number;
    var initialScreenX:Number;
    var initialScreenY:Number;
        
    var saveInitialPos = function(e:MouseEvent):Void {
        initialX = x;
        initialY = y;
        initialWidth = widget.width;
        initialHeight = widget.height;
        initialScreenX = e.sceneX.intValue() + x;
        initialScreenY = e.sceneY.intValue() + y;
    }
    
    function mouseDelta(deltaFunction:function(a:Integer, b:Integer):Void):function(c:MouseEvent):Void {
        return function (e:MouseEvent):Void {
            var xDelta = e.sceneX.intValue() + x - initialScreenX;
            var yDelta = e.sceneY.intValue() + y - initialScreenY;
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
    
    // todo - there is a defect in Javafx which does not allow transparent windows. (their own example doesn't work)
    override var style = StageStyle.UNDECORATED;//if (WidgetFXConfiguration.TRANSPARENT) StageStyle.TRANSPARENT else StageStyle.UNDECORATED;
    override var title = instance.title;
    
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
                        instance.widget.onResize(instance.widget.width, instance.widget.height);
                    }
                    instance.dock();
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
    
    var rolloverOpacity = 0.0;
    var rolloverTimeline = Timeline {
        autoReverse: true
        keyFrames: KeyFrame {time: 500ms, values: rolloverOpacity => 1.0 tween Interpolator.EASEIN}
    }
    
    var firstRollover = true;
        
    var hasFocus:Boolean on replace {
        if (firstRollover) {
            firstRollover = false;
        } else {
            rolloverTimeline.play();
        }
    }
    
    var needsFocus:Boolean;
    
    // this is a workaround for the issue with toggle timelines that are stopped and started immediately triggering a full animation
    function requestFocus(focus:Boolean):Void {
        needsFocus = focus;
        updateFocus();
    }
    
    function updateFocus():Void {
        FX.deferAction (
            function():Void {
                hasFocus = needsFocus or dragging or resizing or changingOpacity;
            }
        );
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
            onMousePressed: function(e) {
                if (e.button == MouseButton.PRIMARY) {
                    dragging = true;
                    saveInitialPos(e);
                }
            }
            onMouseDragged: function(e) {
                if (dragging and not docking) {
                    var hoverOffset:Number[] = [0, 0];
                    for (container in WidgetContainer.containers) {
                        var offset = container.hover(instance, e.screenX, e.screenY, e.x, e.y, true);
                        if (offset != [0, 0]) {
                            hoverOffset = offset;
                        }
                    }
                    mouseDelta(function(xDelta:Integer, yDelta:Integer):Void {
                        x = initialX + xDelta + hoverOffset[0];
                        y = initialY + yDelta + hoverOffset[1];
                    })(e);
                }
            }
            onMouseReleased: function(e) {
                if (e.button == MouseButton.PRIMARY and not docking) {
                    dragging = false;
                    for (container in WidgetContainer.containers) {
                        var targetBounds = container.finishHover(instance, e.screenX, e.screenY);
                        if (targetBounds != null) {
                            dock(targetBounds.x, targetBounds.y);
                        }
                    }
                    instance.saveWithoutNotification();
                }
            }
            opacity: bind if (widget.resizable) rolloverOpacity * 0.8 else 0.0;
        }
        var slider = SwingSlider {
            minimum: 20
            maximum: 99 // todo - hack to prevent swing component defect -- needs further investigation
            value: bind instance.opacity with inverse
            width: width * 2 / 5
        }
        scene = Scene {
            content: [
                dragRect,
                Group { // Widget
                    translateX: BORDER, translateY: BORDER + toolbarHeight
                    cache: true
                    content: Group { // Drop Shadow
                        effect: bind if (resizing) null else DropShadow {offsetX: 2, offsetY: 2, radius: DS_RADIUS}
                        content: Group { // Clip Group
                            content: widget
                            clip: Rectangle {width: bind widget.width, height: bind widget.height}
                        }
                    }
                },
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
                            content: slider
                        }
                    ]
                    opacity: bind rolloverOpacity
                },
                WidgetToolbar {
                    translateX: bind width
                    opacity: bind rolloverOpacity
                    instance: instance
                    onClose: function() {
                        // todo - this will remove widgets from the WidgetRunner, but should be fixed when we refactor the widget lists
                        WidgetManager.getInstance().removeWidget(instance);
                        close();
                    }
                }
            ]
        }
        // todo - find a way to get the window
//        (window as RootPaneContainer).getContentPane().addMouseListener(MouseAdapter {
//            override function mouseEntered(e) {
//                requestFocus(true);
//            }
//            override function mouseExited(e) {
//                requestFocus(false);
//            }
//        });
//        slider.getJSlider().addMouseListener(MouseAdapter {
//            override function mouseEntered(e) {
//                requestFocus(true);
//            }
//            override function mouseExited(e) {
//                requestFocus(false);
//            }
//            override function mousePressed(e) {
//                changingOpacity = true;
//            }
//            override function mouseReleased(e) {
//                changingOpacity = false;
//                instance.saveWithoutNotification();
//            }
//        });
//        visible = true;
    }

}
