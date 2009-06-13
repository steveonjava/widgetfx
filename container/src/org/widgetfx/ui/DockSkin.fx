/*
 * WidgetFX - JavaFX Desktop Widget Platform
 * Copyright (c) 2008-2009, WidgetFX Group
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 1. Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 * 3. Neither the name of WidgetFX nor the names of its contributors may be used
 *    to endorse or promote products derived from this software without
 *    specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */
package org.widgetfx.ui;

import org.widgetfx.*;
import org.widgetfx.layout.*;
import javafx.animation.*;
import javafx.lang.*;
import javafx.scene.*;
import javafx.scene.effect.*;
import javafx.scene.image.*;
import javafx.scene.input.*;
import javafx.scene.layout.*;
import javafx.scene.paint.*;
import javafx.scene.shape.*;
import javafx.ext.swing.SwingUtils;

/**
 * @author Stephen Chin
 */
public var BORDER = 5;
public var DS_RADIUS = 5;

public class DockSkin extends CustomNode, Resizable {

    override function getPrefHeight(width) {-1}
    override function getPrefWidth(height) {-1}

    override function contains( x:Float, y:Float):Boolean{
        return true;
    }
    override function intersects( x:Float, y:Float, width: Float, height:Float):Boolean{
        return true;
    }
    
    public var logoX:Number = 12;
    public var logoY:Number = 7;
    public var logoImage:java.awt.image.BufferedImage = Image {
        url: "{__DIR__}images/WidgetFX-Logo.png"
    }.platformImage as java.awt.image.BufferedImage;
    public var jfxLogoImage = bind SwingUtils.toFXImage(logoImage);
    public var backgroundStartColor = Color.color(0.0, 0.0, 0.0, 0.2);
    public var backgroundEndColor = Color.color(0.0, 0.0, 0.0, 0.5);
    public var logoIcon:java.awt.image.BufferedImage = Image {
        url: "{__DIR__}images/WidgetFXIcon16.png"
    }.platformImage as java.awt.image.BufferedImage on replace {
        dockDialog.tray.setImage(logoIcon);
    }
    public var showDeviceBar = false;

    package public-init var dockDialog:DockDialog;

    var logo:Node = Group {
        translateX: bind if (logoX < 0) width + logoX else logoX
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
        translateX: bind (width - deviceBar.layoutBounds.width) / 2
        translateY: bind height - 87
        opacity: bind rolloverOpacity
    }
    
    package var container:WidgetContainer = WidgetContainer {
        def widgetManager =WidgetManager.getInstance();
        window: bind dockDialog.dialog
        rolloverOpacity: bind rolloverOpacity
        drawShadows: bind not dockDialog.resizing
        translateX: BORDER
        translateY: bind headerHeight
        widgets: bind widgetManager.widgets with inverse
        width: bind width - BORDER * 2
        height: bind height - headerHeight
        gapBox: GapVBox {}
        visible: bind visible
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
        keyFrames: [
            at (0ms) {rolloverOpacity => 0.0}
            at (500ms) {rolloverOpacity => 1.0 tween Interpolator.EASEIN}
        ]
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
            })
        }
    }
    
    var dragBar:Group = Group { // Drag Bar
        blocksMouse: true
        content: [
            Line {endY: bind height, stroke: Color.BLACK, strokeWidth: 1, opacity: bind rolloverOpacity * .175, translateX: bind if (dockDialog.dockLeft) 2 else 0},
            Line {endY: bind height, stroke: Color.BLACK, strokeWidth: 1, opacity: bind rolloverOpacity * .7, translateX: 1},
            Line {endY: bind height, stroke: Color.WHITE, strokeWidth: 1, opacity: bind rolloverOpacity * .23, translateX: bind if (dockDialog.dockLeft) 2 else 0}
        ]
        translateX: bind if (dockDialog.dockLeft) width - dragBar.boundsInLocal.width else 0
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

    override function create() {
        Group {
            content: bind [
                logo,
                if (showDeviceBar) deviceBar else [],
                container,
                dragBar
            ]
        }
    }
}
