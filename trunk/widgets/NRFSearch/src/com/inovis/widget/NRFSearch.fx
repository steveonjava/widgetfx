/*
 * NRFSearch.fx
 *
 * Created on Sep 19, 2008, 6:00:26 PM
 */

package com.inovis.widget;

import org.w3c.dom.Element;
import org.w3c.dom.NodeList;
import org.widgetfx.*;
import javafx.application.*;
import javafx.scene.shape.*;
import javafx.scene.paint.*;
import javafx.scene.image.*;
import javafx.ext.swing.*;
import javafx.scene.*;
import javafx.scene.layout.*;
import javafx.scene.text.*;
import javafx.scene.effect.*;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.xpath.XPathFactory;
import javax.xml.xpath.XPathConstants;

/**
 * @author Stephen Chin
 * @author Keith Comb
 */
var searchText:String;
var colorList:ListItem[];

public function doSearch():Void {
    var builder = DocumentBuilderFactory.newInstance().newDocumentBuilder();
    var document = builder.parse("http://catalogue.inovis.com/QRSGUI/widget/nrfColorCodes?ss={searchText}");
    var xpath = XPathFactory.newInstance().newXPath();
    var colorCodes = xpath.evaluate("//colorCodeNrf", document, XPathConstants.NODESET) as NodeList;
    colorList = for (i in [0..colorCodes.getLength()-1]) {
        var element = colorCodes.item(i) as Element;
        var colorCode = element.getElementsByTagName("colorCode").item(0).getTextContent();
        var color = element.getElementsByTagName("color").item(0).getTextContent();
        var colorGroup = element.getElementsByTagName("colorGroup").item(0).getTextContent();
        ListItem {
            text: "{colorCode} - {color} / {colorGroup}"
        }
    }
}

Widget {
    var transparent = Color.rgb(0, 0, 0, 0);
    var border = 5;
    var titleHeight = 44;
    var textHeight = 25;
    var width = 300;
    var height = 250;
    
    var searchField = ComponentView {
        translateX: 3
        blocksMouse: true
        component: TextField {
            x: 30
            borderless: true
            selectOnFocus: true
            preferredSize: [200, textHeight]
            font: Font {
                size: 11
            }
            background: transparent
            text: bind searchText with inverse
            action: doSearch
        }
    }
    
    onStart: function() {
        searchField.requestFocus();
    }
    
    stage: Stage {
        width: width
        height: height
        content: [
            Rectangle {
                width: width
                height: height
                arcHeight: 7
                arcWidth: 7
                fill: Color.rgb(0xD0, 0xD8, 0xD8);
            },
            VBox {
                content: [
                    ImageView {
                        image: Image {url: "{__DIR__}images/logo.png"}
                    },
                    Rectangle {
                        height: border, fill: transparent
                    },
                    ComponentView {
                        effect: InnerShadow {
                            radius: 4
                            offsetX: 2
                            offsetY: 2
                        }
                        translateX: border
                        blocksMouse: true
                        component: List {
                            preferredSize: [width - border * 2, height - titleHeight - border * 2 - 58]
                            items: bind colorList
                            font: Font {
                                size: 11
                            }
                        }
                    },
                    Text {
                        translateX: border + 3
                        textOrigin: TextOrigin.TOP
                        content: "Search"
                        fill: Color.rgb(0x66, 0x66, 0x66)
                        font: Font {
                            size: 11
                            style: FontStyle.BOLD
                        }
                    },
                    Rectangle {
                        height: 2, fill: transparent
                    },
                    HBox {
                        translateX: border + 3
                        content: [
                            Group {
                                content: [
                                    Rectangle {
                                        width: 203
                                        height: textHeight
                                        arcHeight: 7
                                        arcWidth: 7
                                        fill: Color.WHITE
                                        effect: InnerShadow {
                                            radius: 4
                                            offsetX: 2
                                            offsetY: 2
                                        }                                
                                    },
                                    searchField
                                ]
                            },
                            ComponentView {
                                blocksMouse: true
                                component: Button {
                                    text: "Search"
                                    action: doSearch
                                }
                            }
                        ]
                    }
                ]
            }
        ]
    }
}