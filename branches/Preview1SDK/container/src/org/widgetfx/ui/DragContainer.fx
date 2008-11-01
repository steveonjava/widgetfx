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

/**
 * @author Stephen Chin
 */
public abstract class DragContainer {
    
    public attribute instance:WidgetInstance;
    
    public attribute dragging = false;
    
    public attribute docking = false;
    
    public attribute needsInitialXY = false;
    
    public attribute initialX:Integer;
    
    public attribute initialY:Integer;
    
    public attribute initialScreenX:Integer;
    
    public attribute initialScreenY:Integer;
    
    public function prepareDrag(dragX:Integer, dragY:Integer, screenX:Integer, screenY:Integer) {
        dragging = true;
        needsInitialXY = true;
        initialScreenX = screenX;
        initialScreenY = screenY;
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
            if (needsInitialXY) { // wait until the last moment to do this so the subclass can position the frame
                needsInitialXY = false;
                initialX = instance.frame.x;
                initialY = instance.frame.y;
            }
            instance.frame.x = initialX + screenX - initialScreenX + hoverOffset[0];
            instance.frame.y = initialY + screenY - initialScreenY + hoverOffset[1];
        }
    }
    
    public function finishDrag(screenX:Integer, screenY:Integer) {
        if (dragging and not docking) {
            dragging = false;
            for (container in WidgetContainer.containers) {
                var targetBounds = container.finishHover(instance, screenX, screenY);
                dragComplete(targetBounds);
            }
            instance.saveWithoutNotification();
        }
    }
    
    protected abstract function dragComplete(targetBounds:java.awt.Rectangle):Void;
}
