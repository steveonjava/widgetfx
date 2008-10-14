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
import javafx.lang.*;
import javafx.scene.*;
import org.widgetfx.*;

/**
 * @author Stephen Chin
 * @author Keith Combs
 */
public var containers:WidgetContainer[];

public class WidgetContainer extends Group {
    
    public var widgets:WidgetInstance[];
    
    // if this is set, copy widget when dropped on a new container, but place the original
    // widget back in the source container
    public-init var copyOnContainerDrop:Boolean;
    
    public-init var layout:GapBox on replace {
        layout.maxWidth = width;
        layout.maxHeight = height;
        layout.content = widgetViews;
        content = [layout];
    }
    
    public var width:Number on replace {
        layout.maxWidth = width;
    }
    
    public var height:Number on replace {
        layout.maxHeight = height;
    }
    
    public var resizing:Boolean;
    
    public var dragging:Boolean;
    
    var widgetViews:WidgetView[] = bind for (instance in widgets) createWidgetView(instance) on replace {
        layout.content = widgetViews;
    }
    
    function createWidgetView(instance:WidgetInstance):WidgetView {
        return WidgetView {
            container: this
            instance: instance
        }
    }
    
    var animateHover:Timeline;
    var animatingInstance:WidgetInstance;
    var animating = bind if (animateHover == null) false else animateHover.running on replace {
        animatingInstance.frame.resizing = animating;
    }
    var animateDocked:Boolean;
    var saveUndockedWidth:Number;
    var saveUndockedHeight:Number;
    var xHoverOffset:Number;
    var yHoverOffset:Number;
    
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
                autoReverse: true
                keyFrames: KeyFrame {
                    time: 300ms
                    values: [
                        if (newWidth > 0) {[
                            instance.widget.width => newWidth tween Interpolator.EASEBOTH,
                            xHoverOffset => localX - localX * newWidth / instance.widget.width tween Interpolator.EASEBOTH
                        ]} else {
                            []
                        },
                        if (newHeight > 0) {[
                            instance.widget.height => newHeight tween Interpolator.EASEBOTH,
                            yHoverOffset => localY - localY * newHeight / instance.widget.height tween Interpolator.EASEBOTH
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
        if (layout.containsScreenXY(screenX, screenY)) {
            delete instance from widgets;
            var dockedHeight = if (instance.dockedHeight == 0) instance.widget.height else instance.dockedHeight;
            layout.setGap(screenX, screenY, dockedHeight + Dock.DS_RADIUS * 2 + 2, animate);
            if (animateHover != null and not animateDocked) {
                animateDocked = true;
                animateHover.play();
            }
        } else {
            layout.clearGap(animate);
            if (animateHover != null and animateDocked) {
                animateDocked = false;
                animateHover.play();
            }
        }
        return [xHoverOffset, yHoverOffset];
    }
    
    public function finishHover(instance:WidgetInstance, screenX:Integer, screenY:Integer):java.awt.Rectangle {
        if (layout.containsScreenXY(screenX, screenY)) {
            animateHover.stop();
            animateHover = null;
            instance.undockedWidth = saveUndockedWidth;
            instance.undockedHeight = saveUndockedHeight;
            return layout.getGapScreenBounds();
        } else {
            if (animateHover != null and animateDocked) {
                animateDocked = false;
                animateHover.play();
            }
            animateHover = null;
            return null;
        }
    }
    
    public function dockAfterHover(instance:WidgetInstance) {
        instance.docked = true;
        insert instance before widgets[layout.getGapIndex()];
        layout.clearGap(false);
        layout.doLayout();
    }
}
