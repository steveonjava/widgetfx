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
import javafx.animation.*;
import javafx.lang.*;
import javafx.scene.*;
import javafx.scene.effect.*;
import javafx.scene.control.*;
import javafx.scene.image.*;
import javafx.scene.input.*;
import javafx.scene.layout.*;
import javafx.scene.paint.*;
import javafx.scene.shape.*;
import javafx.scene.text.*;
import javafx.stage.*;
import javafx.ext.swing.*;

/**
 * @author Stephen Chin
 */
public var BORDER = 5;
public var DS_RADIUS = 5;

public class DockSkin extends Skin {
    public var logoX:Number = 12;
    public var logoY:Number = 7;
    public var logoImage:java.awt.image.BufferedImage = Image {
        url: "{__DIR__}images/WidgetFX-Logo.png"
    }.bufferedImage;
    public var jfxLogoImage = bind Image{}.fromBufferedImage(logoImage);
    public var backgroundStartColor = Color.color(0.0, 0.0, 0.0, 0.2);
    public var backgroundEndColor = Color.color(0.0, 0.0, 0.0, 0.5);
    public var logoIcon:java.awt.image.BufferedImage = Image {
        url: "{__DIR__}images/WidgetFXIcon16.png"
    }.bufferedImage on replace {
        dockDialog.tray.setImage(logoIcon);
    }
    public var showDeviceBar = false;

    package public-init var dockDialog:DockDialog;

    var logo:Node = Group {
        translateX: bind if (logoX < 0) control.width + logoX else logoX
        translateY: bind logoY
        effect: bind if (logo.hover) Glow {level: 0.7} else null
        var imageView = ImageView {
            image: bind jfxLogoImage
        }
        content: [
            Rectangle {
                width: bind imageView.boundsInLocal.width
                height: bind imageView.boundsInLocal.height
                fill: Color.TRANSPARENT
            },
            imageView
        ]
        onMouseReleased: function(e:MouseEvent) {
            dockDialog.showMenu(e.sceneX, e.sceneY);
        }
    }
    var headerHeight:Integer = bind BORDER * 2 + logo.boundsInLocal.height.intValue();
    var deviceBar:DeviceBar = DeviceBar {
        owner: dockDialog
        translateX: bind (control.width - deviceBar.layoutBounds.width) / 2
        translateY: bind control.height - 87
        opacity: bind rolloverOpacity
    }
    
    package var container:WidgetContainer = WidgetContainer {
        window: bind dockDialog.dialog
        rolloverOpacity: bind rolloverOpacity
        drawShadows: bind not dockDialog.resizing
        translateX: BORDER
        translateY: bind headerHeight
        widgets: bind WidgetManager.getInstance().widgets with inverse
        width: bind control.width - BORDER * 2
        height: bind control.height - headerHeight
        layout: GapVBox {}
        visible: bind control.visible
    }

    var leftBG = bind LinearGradient {
        endY: 0
        stops: [
            Stop {offset: 0.0, color: backgroundEndColor},
            Stop {offset: 1.0, color: backgroundStartColor}
        ]
    }
    var rightBG = bind LinearGradient {
        endY: 0
        stops: [
            Stop {offset: 0.0, color: backgroundStartColor},
            Stop {offset: 1.0, color: backgroundEndColor}
        ]
    }
    package var transparentBG = bind if (dockDialog.dockLeft) leftBG else rightBG;
    
    package var rolloverOpacity = 0.0;
    package var rolloverTimeline = Timeline {
        keyFrames: at (500ms) {rolloverOpacity => 1 tween Interpolator.EASEIN}
    }

    var hoverDock = bind dockDialog.mouseOver or container.widgetDragging or dockDialog.draggingDock or dockDialog.resizing on replace oldValue {
        // Defer the action to prevent spurious, alternating updates
        if (hoverDock != oldValue) {
            FX.deferAction(function ():Void {
                    // Check the time to make sure we don't run over the end of the animation and reset it
                    if ((hoverDock and rolloverTimeline.time < 500ms) or (not hoverDock and rolloverTimeline.time > 0s)) {
                        rolloverTimeline.rate = if (hoverDock) 1 else -1;
                        rolloverTimeline.play();
                    }
                }
            )
        }
    }
    
    var dragBar:Group = Group { // Drag Bar
        blocksMouse: true
        content: [
            Line {endY: bind control.height, stroke: Color.BLACK, strokeWidth: 1, opacity: bind rolloverOpacity * .175},
            Line {endY: bind control.height, stroke: Color.BLACK, strokeWidth: 1, opacity: bind rolloverOpacity * .7, translateX: 1},
            Line {endY: bind control.height, stroke: Color.WHITE, strokeWidth: 1, opacity: bind rolloverOpacity * .23, translateX: 2}
        ]
        translateX: bind if (dockDialog.dockLeft) control.width - dragBar.boundsInLocal.width else 0
        cursor: Cursor.H_RESIZE
        onMouseDragged: dockDialog.resizeDragged
        onMouseReleased: function(e) {
            for (instance in container.dockedWidgets) {
                if (instance.widget.resizable) {
                    if (instance.widget.onResize != null) {
                        instance.widget.onResize(instance.widget.width, instance.widget.height);
                    }
                    instance.saveWithoutNotification();
                }
            }
            dockDialog.resizeReleased(e);
        }
    }

    init {
        scene = Group {
            content: bind [
                logo,
                if (showDeviceBar) deviceBar else [],
                container,
                dragBar
            ]
        }
    }
}
