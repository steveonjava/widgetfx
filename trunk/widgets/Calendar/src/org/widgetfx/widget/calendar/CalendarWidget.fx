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
import org.widgetfx.config.*;
import org.jfxtras.scene.layout.*;
import javafx.ext.swing.*;
import javafx.scene.*;
import javafx.scene.control.*;
import javafx.scene.paint.*;
import javafx.scene.shape.*;
import javafx.scene.text.*;
import javafx.scene.transform.*;
import java.util.*;
import javafx.util.Sequences;

var language:String = Locale.getDefault().getLanguage();
var country:String = Locale.getDefault().getCountry();
var variant:String = Locale.getDefault().getVariant();
var locale = bind new Locale(language, country, variant);

def defaultWidth = 180.0;
def defaultHeight = 200.0;

def scene:Group = Group {
    def arcHeight = defaultHeight / 20;
    def offset = defaultWidth / 25;
    transforms: bind Transform.scale(
        widget.width / defaultWidth,
        widget.height / defaultHeight);
    // scale down by 1% to leave room for stroke width
    scaleX: .99
    scaleY: .99
    content: [
        for (i in reverse [0..3]) {
            createPage(offset*i/3, offset*i/3 + arcHeight,
                       defaultWidth - offset,
                       defaultHeight - offset - arcHeight)
        },
        createSpiral(defaultWidth - offset, arcHeight),
        createPageContents(0, arcHeight * 2,
                           defaultWidth - offset,
                           defaultHeight-offset-arcHeight*2)
    ]
}

def config = Configuration {
    properties: [
        StringProperty {
            name: "language"
            value: bind language with inverse
        },
        StringProperty {
            name: "country"
            value: bind country with inverse
        },
        StringProperty {
            name: "variant"
            value: bind variant with inverse
        }
    ]
    var locales = Locale.getAvailableLocales();
    var localePicker = SwingComboBox {
        items: for (l in Arrays.asList(locales)) {
            SwingComboBoxItem {
                selected: l == locale
                text: l.getDisplayName()
                value: l
            }
        }
    }
    scene: Scene {
        content: Grid {
            rows: [
                Row {
                    cells: [
                        Text {content: "Locale:"},
                        localePicker
                    ]
                }
            ]
        }
    }
    onSave: function() {
        var l = localePicker.selectedItem.value as Locale;
        language = l.getLanguage();
        country = l.getCountry();
        variant = l.getVariant();
    }
    onLoad: function() {
        localePicker.selectedIndex =
            Sequences.indexOf(locales, locale);
    }
}

def widget:Widget = Widget {
    width: defaultWidth
    height: defaultHeight
    aspectRatio: defaultWidth / defaultHeight
    configuration: config
    skin: Skin {
        scene: scene
    }
}

function createPage(x:Number, y:Number,
                    width:Number, height:Number) {
    [
        Rectangle { // Fill
            translateX: x
            translateY: y
            width: width
            height: height
            fill: Color.WHITE
        },
        Rectangle { // Footer
            translateX: x
            translateY: y + height * 6/7
            width: width
            height: height / 7
            fill: Color.MIDNIGHTBLUE
        },
        Rectangle { // Border
            translateX: x
            translateY: y
            width: width
            height: height
            fill: null
            stroke: Color.BLACK
        }
    ]
}

function createSpiral(width:Number, arcHeight:Number) {
    def numArcs = 20;
    for (i in [1..numArcs]) {
        var arcSpacing = width / (numArcs + 2);
        Arc {
            centerX: arcSpacing * (i + 1)
            centerY: arcHeight
            radiusX: arcHeight * 2 / 3
            radiusY: arcHeight
            startAngle: 0
            length: 230
            stroke: Color.BLACK
            fill: null
        }
    }
}

function createPageContents(x:Number, y: Number,
                            width:Number, height:Number) {
    def calendar = Calendar.getInstance();
    def fontHeight = 20;
    def offset = 5;
    def date:Text = Text {
        translateX: bind (width-date.layoutBounds.width)/2
        translateY: bind (height-date.layoutBounds.height)/2
        content: "{calendar.get(Calendar.DAY_OF_MONTH)}"
        font: Font.font("Impact", height * 2 / 3)
        textOrigin: TextOrigin.TOP
    }
    def year:Text = Text {
        translateX: offset
        translateY: offset + fontHeight
        font: Font.font(null, fontHeight)
        content: "{calendar.get(Calendar.YEAR)}"
    }
    def month:Text = Text {
        translateX: bind width - month.layoutBounds.width -
                         offset
        translateY: offset + fontHeight
        font: Font.font(null, fontHeight)
        content: bind
            calendar.getDisplayName(Calendar.MONTH,
                                    Calendar.LONG, locale)
    }
    def dayOfWeek:Text = Text {
        translateX:
            bind (width - dayOfWeek.layoutBounds.width) / 2
        translateY: height - offset * 1.5
        font: Font.font(null, fontHeight)
        content: bind
            calendar.getDisplayName(Calendar.DAY_OF_WEEK,
                                    Calendar.LONG, locale)
        fill: Color.WHITESMOKE
    }
    Group {
        translateX: x
        translateY: y
        content: [date, year, month, dayOfWeek]
    }
}

return widget;
