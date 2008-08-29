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
import javafx.input.*;
import javafx.scene.*;
import javafx.scene.effect.*;
import javafx.scene.geometry.*;

/**
 * @author Stephen Chin
 */
public class WidgetView extends Group {
    
    public attribute instance:WidgetInstance;
    
    private attribute widget = bind instance.widget;
    
    public attribute docking = false;
    
    private attribute dockedParent:Group;
    private attribute lastScreenPosX:Integer;
    private attribute lastScreenPosY:Integer;
    
    init {
        cache = true;
        content = [Group {
            // todo - standard size with and without DropShadow when docked
            effect: bind if (Sidebar.getInstance().resizing) null else DropShadow {offsetX: 2, offsetY: 2, radius: Sidebar.DS_RADIUS}
            content: Group {
                content: widget.stage.content
                clip: Rectangle {width: bind widget.stage.width, height: bind widget.stage.height}
            }
        }];
        onMousePressed = function(e:MouseEvent):Void {
            lastScreenPosX = e.getStageX().intValue();
            lastScreenPosY = e.getStageY().intValue();
        };
        onMouseClicked = function(e:MouseEvent):Void {
            if (e.getButton() == 3) {
                WidgetManager.getInstance().showConfigDialog(widget);
            }
        };
        onMouseDragged = function(e:MouseEvent):Void {
            var sidebar = Sidebar.getInstance();
            if (not docking) {
                if (instance.docked) {
                    sidebar.dragging = true;
                    var xPos = e.getStageX().intValue() + sidebar.x - e.getX().intValue() - WidgetFrame.BORDER;
                    var yPos = e.getStageY().intValue() + sidebar.y - e.getY().intValue() - WidgetFrame.BORDER;
                    instance.frame = WidgetFrame {
                        instance: instance
                        x: xPos, y: yPos
                    }
                    sidebar.hover(instance, xPos, yPos, false);
                    instance.docked = false;
                } else {
                    instance.frame.x += e.getStageX().intValue() - lastScreenPosX;
                    instance.frame.y += e.getStageY().intValue() - lastScreenPosY;
                    lastScreenPosX = e.getStageX().intValue();
                    lastScreenPosY = e.getStageY().intValue();
                    sidebar.hover(instance, e.getScreenX(), e.getScreenY(), true);
                }
            }
        };
        onMouseReleased = function(e:MouseEvent):Void {
            if (not docking and not instance.docked) {
                var targetBounds = Sidebar.getInstance().finishHover(instance, e.getScreenX(), e.getScreenY());
                if (targetBounds != null) {
                    docking = true;
                    instance.frame.dock(targetBounds.x, targetBounds.y);
                } else {
                    if (instance.widget.onResize != null) {
                        instance.widget.onResize(instance.widget.stage.width, instance.widget.stage.height);
                    }
                }
                Sidebar.getInstance().dragging = false;
                instance.saveWithoutNotification();
            }
        };
    }
}
