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

package org.widgetfx.widget.calendar;

/**
 * @author Stephen Chin
 * @author Keith Combs
 */
import org.widgetfx.*;
import javafx.scene.*;
import javafx.scene.control.*;
import javafx.scene.paint.*;
import javafx.scene.shape.*;
import javafx.scene.text.*;
import java.util.Locale;

def calendar = java.util.Calendar.getInstance();

def widget:Widget = Widget {
    width: 180
    height: 200
    aspectRatio: .9
    def offset = bind widget.width / 60;
    def arcHeight = bind widget.width / 20;
    skin: Skin {
        scene: Group {
            content: bind [
                Rectangle {
                    translateX: offset
                    translateY: offset + arcHeight
                    width: widget.width - offset
                    height: widget.height - offset
                    fill: Color.BLACK
                },
                createPage(widget.width - offset, widget.height - offset, arcHeight)
            ]
        }
    }
}

bound function createPage(width:Number, height:Number, arcHeight:Number) {
    Group {
        content: [
            Rectangle {
                translateY: arcHeight
                width: bind width
                height: bind height - arcHeight
                fill: Color.WHITE
            },
            createPageContents(0, arcHeight * 2, width, height - arcHeight * 2),
            Rectangle {
                translateY: arcHeight
                width: bind width
                height: bind height - arcHeight
                strokeWidth: bind java.lang.Math.max(1, width / 150)
                stroke: Color.BLACK
                fill: null
            },
            createSpiral(width, arcHeight)
        ]
    }
}

bound function createSpiral(width:Number, arcHeight:Number) {
    def numArcs = 25;
    var arcSpacing = width / (numArcs + 2);
    for (i in [0..numArcs]) {
        Arc {
            centerX: bind arcSpacing * (i + 1)
            centerY: bind arcHeight
            radiusX: bind arcSpacing * 3/4
            radiusY: bind arcHeight
            startAngle: 0
            length: 270
            stroke: Color.BLACK
            strokeWidth: bind java.lang.Math.max(1, width / 200)
            fill: null
        }
    }
}

bound function createPageContents(x:Number, y: Number, width:Number, height:Number) {
    var date:Text;
    var year:Text;
    var month:Text;
    var backDrop:Rectangle;
    var dayOfWeek:Text;
    var fontHeight = bind height / 10;
    def offset = bind width / 40;
    Group {
        translateX: bind x
        translateY: bind y
        content: [
            date = Text {
                translateX: bind (width - date.layoutBounds.width) / 2
                translateY: bind (height - date.layoutBounds.height) / 2
                content: "{calendar.get(java.util.Calendar.DAY_OF_MONTH)}"
                font: bind Font.font("Impact", height * 2 / 3)
                textOrigin: TextOrigin.TOP
            },
            year = Text {
                translateX: bind offset
                translateY: bind offset + fontHeight
                font: bind Font.font(null, fontHeight)
                content: "{calendar.get(java.util.Calendar.YEAR)}"
            },
            month = Text {
                translateX: bind width - month.layoutBounds.width - offset
                translateY: bind offset + fontHeight
                font: bind Font.font(null, fontHeight)
                content: calendar.getDisplayName(java.util.Calendar.MONTH, java.util.Calendar.LONG, Locale.getDefault())
            },
            backDrop = Rectangle {
                translateY: bind height - backDrop.layoutBounds.height;
                width: bind width
                height: bind 2 * offset + fontHeight
                fill: Color.MIDNIGHTBLUE
            },
            dayOfWeek = Text {
                translateX: bind (width - month.layoutBounds.width) / 2
                translateY: bind height - offset * 1.5
                font: bind Font.font(null, fontHeight)
                content: calendar.getDisplayName(java.util.Calendar.DAY_OF_WEEK, java.util.Calendar.LONG, Locale.getDefault())
                fill: Color.WHITESMOKE
            }
        ]
    }
}

return widget
