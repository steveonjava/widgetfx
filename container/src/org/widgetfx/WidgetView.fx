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

    public attribute sidebar:Sidebar;
    
    public attribute widget:Widget;
    
    public attribute docked = true;
    
    public attribute docking = false;
    
    private attribute dockedParent:Group;
    private attribute widgetFrame:WidgetFrame;
    private attribute lastScreenPosX:Integer;
    private attribute lastScreenPosY:Integer;
    
    init {
        cache = true;
        content = [Group {
            // todo - standard size with and without DropShadow when docked
            effect: bind if (sidebar.resizing) null else DropShadow {offsetX: 2, offsetY: 2, radius: Sidebar.DS_RADIUS}
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
            if (not docking) {
                if (docked) {
                    sidebar.dragging = true;
                    var xPos = e.getStageX().intValue() + sidebar.x - e.getX().intValue() - WidgetFrame.BORDER;
                    var yPos = e.getStageY().intValue() + sidebar.y - e.getY().intValue() - WidgetFrame.BORDER;
                    delete this from sidebar.widgetViews;
                    widgetFrame = WidgetFrame {
                        sidebar: sidebar;
                        widget: widget;
                        x: xPos, y: yPos
                        // todo - add opacity to configuration and save
                        opacity: 0.8
                    }
                    docked = false;
                    sidebar.hover(widget, e.getScreenX(), e.getScreenY(), false);
                } else {
                    widgetFrame.x += e.getStageX().intValue() - lastScreenPosX;
                    widgetFrame.y += e.getStageY().intValue() - lastScreenPosY;
                    lastScreenPosX = e.getStageX().intValue();
                    lastScreenPosY = e.getStageY().intValue();
                    sidebar.hover(widget, e.getScreenX(), e.getScreenY(), true);
                }
            }
        };
        onMouseReleased = function(e:MouseEvent):Void {
            if (not docking and not docked) {
                var screenX = e.getScreenX();
                var screenY = e.getScreenY();
                var targetBounds = sidebar.hover(widget, screenX, screenY, true);
                if (targetBounds != null) {
                    docking = true;
                    widgetFrame.dock(targetBounds.x, targetBounds.y, screenX, screenY);
                }
                sidebar.dragging = false;
            }
        };
    }
}
