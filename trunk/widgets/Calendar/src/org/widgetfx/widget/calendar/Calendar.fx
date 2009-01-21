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
import java.util.*;

var language:String = Locale.getDefault().getLanguage();
var country:String = Locale.getDefault().getCountry();
var variant:String = Locale.getDefault().getVariant();
var locale = bind new Locale(language, country, variant);

def calendar = java.util.Calendar.getInstance();

def widget:Widget = Widget {
    width: 180
    height: 200
    aspectRatio: .9
//    configuration: Configuration {
//        properties: [
//            StringProperty {
//                name: "language"
//                value: bind language with inverse
//            },
//            StringProperty {
//                name: "country"
//                value: bind country with inverse
//            },
//            StringProperty {
//                name: "variant"
//                value: bind variant with inverse
//            }
//        ]
//        var localePicker = SwingComboBox {
//            items: for (l in Arrays.asList(Locale.getAvailableLocales())) {
//                SwingComboBoxItem {
//                    selected: l == locale
//                    text: l.getDisplayName()
//                    value: l
//                }
//            }
//        }
//        scene: Scene {
//            content: Grid {
//                rows: [
//                    Row {
//                        cells: [
//                            Text {content: "Locale:"},
//                            localePicker
//                        ]
//                    }
//                ]
//            }
//        }
//        onSave: function() {
//            var l = localePicker.selectedItem.value as Locale;
//            language = l.getLanguage();
//            country = l.getCountry();
//            variant = l.getVariant();
//        }
//    }
    skin: Skin {
        scene: Group {
            def arcHeight = bind widget.width / 20;
            def offset = bind widget.width / 25;
            content: bind [
                for (i in reverse [0..3]) {
                    createPage(offset * i / 3, offset * i / 3 + arcHeight, widget.width - offset - 1, widget.height - offset - 1 - arcHeight)
                },
                createSpiral(widget.width - offset - 1, arcHeight),
                createPageContents(0, arcHeight * 2, widget.width - offset - 1, widget.height - offset - 1 - arcHeight * 2)
            ]
        }
    }
}

bound function createPage(x:Number, y:Number, width:Number, height:Number):Group {
    Group {
        content: [
            Rectangle {
                translateX: x
                translateY: y
                width: bind width
                height: bind height
                fill: Color.WHITE
            },
            Rectangle {
                translateX: x
                translateY: y + height - height / 7
                width: bind width
                height: bind height / 7
                fill: Color.MIDNIGHTBLUE
            },
            Rectangle {
                translateX: x
                translateY: y
                width: bind width
                height: bind height
                fill: null
                strokeWidth: bind java.lang.Math.max(1, widget.width / 180)
                stroke: Color.BLACK
            }
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
                content: bind calendar.getDisplayName(java.util.Calendar.MONTH, java.util.Calendar.LONG, locale)
            },
            dayOfWeek = Text {
                translateX: bind (width - month.layoutBounds.width) / 2
                translateY: bind height - offset * 1.5
                font: bind Font.font(null, fontHeight)
                content: bind calendar.getDisplayName(java.util.Calendar.DAY_OF_WEEK, java.util.Calendar.LONG, locale)
                fill: Color.WHITESMOKE
            }
        ]
    }
}

return widget;
