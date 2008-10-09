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

import javafx.animation.*;
import javafx.application.*;
import javafx.lang.*;
import javafx.scene.*;
import org.widgetfx.*;

/**
 * @author Stephen Chin
 * @author Keith Combs
 */
public class WidgetContainer extends Group {
    
    public static attribute containers:WidgetContainer[];
    
    public attribute window:Window;
    
    public attribute widgets:WidgetInstance[];
    
    // if this is set, copy widget when dropped on a new container, but place the original
    // widget back in the source container
    public attribute copyOnContainerDrop:Boolean;
    
    public attribute layout:GapBox on replace {
        layout.width = width;
        layout.height = height;
        layout.content = widgetViews;
        content = [layout];
    }
    
    public attribute width:Integer on replace {
        layout.width = width;
        for (widget in widgets) {
            updateWidth(widget);
        }
    }
    
    public attribute columnWidth = bind layout.nodeWidth.intValue();
    
    public attribute height:Integer on replace {
        layout.height = height;
    }
    
    public attribute resizing:Boolean;
    
    public attribute dragging:Boolean;
    
    // todo - this needs to be calculated off the globalToLocal transform (then this parameter goes away)
    public attribute headerHeight;
    
    private attribute widgetViews:Node[] = bind for (instance in widgets) createWidgetView(instance) on replace {
        layout.content = widgetViews;
    }
    
    private function createWidgetView(instance:WidgetInstance):WidgetView {
        updateWidth(instance);
        return WidgetView {
            container: this
            instance: instance
        }
    }
    
    private function updateWidth(instance:WidgetInstance):Void {
        if (instance.widget.resizable) {
            instance.widget.stage.width = columnWidth;
            if (instance.widget.aspectRatio != 0) {
                instance.widget.stage.height = (instance.widget.stage.width / instance.widget.aspectRatio).intValue();
            }
        }
    }
    
    private attribute animateHover:Timeline;
    private attribute animatingInstance:WidgetInstance;
    private attribute animating = bind if (animateHover == null) false else animateHover.running on replace {
        animatingInstance.frame.resizing = animating;
    }
    private attribute animateDocked:Boolean;
    private attribute saveUndockedWidth:Integer;
    private attribute saveUndockedHeight:Integer;
    private attribute xHoverOffset;
    private attribute yHoverOffset;
    
    init {
        insert this into containers;
    }
    
    public function setupHoverAnimation(instance:WidgetInstance, localX:Integer, localY:Integer) {
        if (animateHover == null) {
            animatingInstance = instance;
            xHoverOffset = 0;
            yHoverOffset = 0;
            saveUndockedWidth = instance.undockedWidth;
            saveUndockedHeight = instance.undockedHeight;
            var newWidth = if (instance.docked) instance.undockedWidth else instance.dockedWidth;
            var newHeight = if (instance.docked) instance.undockedHeight else instance.dockedHeight;
            animateHover = Timeline {
                autoReverse: true, toggle: true
                keyFrames: KeyFrame {
                    time: 300ms
                    values: [
                        if (newWidth > 0) {[
                            instance.widget.stage.width => newWidth tween Interpolator.EASEBOTH,
                            xHoverOffset => localX - localX * newWidth / instance.widget.stage.width tween Interpolator.EASEBOTH
                        ]} else {
                            []
                        },
                        if (newHeight > 0) {[
                            instance.widget.stage.height => newHeight tween Interpolator.EASEBOTH,
                            yHoverOffset => localY - localY * newHeight / instance.widget.stage.height tween Interpolator.EASEBOTH
                        ]} else {
                            []
                        }
                    ]
                }
            }
            animateDocked = instance.docked;
        }
    }
    
    public function hover(instance:WidgetInstance, screenX:Integer, screenY:Integer, localX:Integer, localY:Integer, animate:Boolean) {
        setupHoverAnimation(instance, localX, localY);
        if (visible and screenX >= window.x and screenX < window.x + width and screenY >= window.y and screenY < window.y + height) {
            var dockedHeight = if (instance.dockedHeight == 0) instance.widget.stage.height else instance.dockedHeight;
            layout.setGap(screenX, screenY, dockedHeight + Dock.DS_RADIUS * 2 + 2, animate);
            if (animateHover != null and not animateDocked) {
                animateDocked = true;
                animateHover.start();
            }
        } else {
            layout.clearGap(animate);
            if (animateHover != null and animateDocked) {
                animateDocked = false;
                animateHover.start();
            }
        }
        return [xHoverOffset, yHoverOffset];
    }
    
    public function finishHover(instance:WidgetInstance, screenX:Integer, screenY:Integer):java.awt.Rectangle {
        if (visible and screenX >= window.x and screenX < window.x + width and screenY >= window.y and screenY < window.y + height) {
            animateHover.stop();
            animateHover = null;
            instance.undockedWidth = saveUndockedWidth;
            instance.undockedHeight = saveUndockedHeight;
            return new java.awt.Rectangle(
                window.x + (width - instance.widget.stage.width) / 2,
                window.y + layout.getGapLocation() + headerHeight + WidgetView.TOP_BORDER,
                instance.widget.stage.width,
                instance.widget.stage.height
            );
        } else {
            if (animateHover != null and animateDocked) {
                animateDocked = false;
                animateHover.start();
            }
            animateHover = null;
            return null;
        }
    }
    
    public function dockAfterHover(instance:WidgetInstance) {
        delete instance from WidgetManager.getInstance().widgets;
        instance.docked = true;
        if (layout.getGapIndex() >= widgets.size()) {
            insert instance into WidgetManager.getInstance().widgets;
        } else {
            var index = Sequences.indexOf(WidgetManager.getInstance().widgets, widgets[layout.getGapIndex()]);
            insert instance before WidgetManager.getInstance().widgets[index];
        }
        layout.clearGap(false);
    }
}
