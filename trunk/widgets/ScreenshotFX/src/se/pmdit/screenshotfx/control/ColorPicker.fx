/*
 * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER
 * Copyright 2009 Sun Microsystems, Inc. All rights reserved. Use is subject to license terms.
 *
 * This file is available and licensed under the following license:
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *   * Redistributions of source code must retain the above copyright notice,
 *     this list of conditions and the following disclaimer.
 *
 *   * Redistributions in binary form must reproduce the above copyright notice,
 *     this list of conditions and the following disclaimer in the documentation
 *     and/or other materials provided with the distribution.
 *
 *   * Neither the name of Sun Microsystems nor the names of its contributors
 *     may be used to endorse or promote products derived from this software
 *     without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
 * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 * ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

package se.pmdit.screenshotfx.control;

import javafx.scene.CustomNode;
import javafx.scene.Group;
import javafx.scene.Node;
import javafx.scene.paint.Color;
import javafx.scene.shape.ClosePath;
import javafx.scene.shape.Line;
import javafx.scene.shape.LineTo;
import javafx.scene.shape.MoveTo;
import javafx.scene.shape.Path;
import javafx.scene.shape.Rectangle;

/**
 * @author Rakesh Menon
 *
 * Note from Pär Dahlberg:
 * Code taken from http://blogs.sun.com/rakeshmenonp/entry/javafx_color_picker
 * and added to this package
 */

public class ColorPicker extends CustomNode {

    public-init var color : Color = Color.BLACK;

    public var updateColor: function(clr : Color) = null;
    public var width: Number = 40;
    public var height: Number = 20;

    var colorPalette = ColorPalette {
        translateX: 0
        translateY: 22
    };

    var colorRect = Rectangle {
        width: bind width
        height: bind height
        strokeWidth: 3.0
        stroke: Color.WHITE
        fill: bind color
        onMousePressed: function(e) {

            requestFocus();

            // Ensure that we are not adding twice
            delete colorPalette from scene.content;
            insert colorPalette into scene.content;

            colorPalette.translateX = e.sceneX - e.x;
            colorPalette.translateY = e.sceneY - e.y + 22;
            colorPalette.show = not colorPalette.show;
        }
    }

    var borderRect = Rectangle {
        x: 1
        y: 1
        width: 38
        height: 18
        strokeWidth: 1.0
        stroke: Color.web("#E6E6E6")
        fill: Color.TRANSPARENT
    }

    var vLine1 = Line {
        startX: 2
        startY: 2
        endX: 2
        endY: 17
        stroke: Color.web("#9B9B9B")
    }

    var hLine1 = Line {
        startX: 2
        startY: 2
        endX: 37
        endY: 2
        stroke: Color.web("#9B9B9B")
    }

    var vLine2 = Line {
        startX: 41
        startY: 0
        endX: 41
        endY: 20
        stroke: Color.web("#9B9B9B")
    }

    var hLine2 = Line {
        startX: 0
        startY: 21
        endX: 40
        endY: 21
        stroke: Color.web("#9B9B9B")
    }

    var arrow = Path {
        translateX: 31
        translateY: 15
        elements: [
            MoveTo { x: 0.0 y: 0.0 },
            LineTo { x: 8.0 y: 0.0 },
            LineTo { x: 4.0 y: 4.0 },
            ClosePath { }
        ]
        strokeWidth: 1.0
        fill: Color.BLACK
        stroke: Color.web("#9B9B9B")
    };

    var initialized = false;
    var cpColor = bind colorPalette.selectedColor on replace {
        if(initialized) {
            color = cpColor;
            if(updateColor != null) {
                updateColor(color);
            }
        }
    };

    init {

        if(color == null) {
            color = colorPalette.selectedColor;
        } else {
            colorPalette.selectedColor = color;
        }

        focusTraversable = true;
        initialized = true;
    }

    override function create() : Node {

        focusTraversable = true;

        colorPalette.selectedColor = color;

        Group {
            content: [
                colorRect,
                borderRect,
                vLine1,
                hLine1,
                vLine2,
                hLine2,
                arrow
            ]
        };
    }

    override var focused on replace {
        if(not focused) {
            colorPalette.show = false;
        }
    }
}
