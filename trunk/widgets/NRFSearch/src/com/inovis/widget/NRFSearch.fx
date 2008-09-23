/*
 * NRFSearch.fx
 *
 * Created on Sep 19, 2008, 6:00:26 PM
 */

package com.inovis.widget;

import org.widgetfx.*;
import javafx.application.*;
import javafx.scene.geometry.*;
import javafx.scene.paint.*;
import javafx.scene.image.*;
import javafx.ext.swing.*;
import javafx.scene.*;
import javafx.scene.layout.*;
import javafx.scene.text.*;
import javafx.scene.effect.*;

/**
 * @author Stephen Chin
 * @author Keith Comb
 */
Widget {
    var transparent = Color.rgb(0, 0, 0, 0);
    var border = 5;
    var titleHeight = 44;
    var textHeight = 25;
    var width = 300;
    var height = 250;
    
    var searchText:String;
    
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
                            items: [
                                ListItem {
                                    text: "First Item";
                                },
                                ListItem {
                                    text: "Second Item";
                                },
                                ListItem {
                                    text: "Third Item";
                                },
                                ListItem {
                                    text: "Fourth Item";
                                },
                                ListItem {
                                    text: "Fifth Item";
                                },
                                ListItem {
                                    text: "First Item";
                                },
                                ListItem {
                                    text: "Second Item";
                                },
                                ListItem {
                                    text: "Third Item";
                                },
                                ListItem {
                                    text: "Fourth Item";
                                },
                                ListItem {
                                    text: "Fifth Item";
                                }
                            ]
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
                                    ComponentView {
                                        translateX: 3
                                        blocksMouse: true
                                        component: TextField {
                                            x: 30
                                            borderless: true
                                            preferredSize: [200, textHeight]
                                            font: Font {
                                                size: 11
                                            }
                                            background: transparent
                                            text: bind searchText with inverse
                                        }
                                    }
                                ]
                            },
                            ComponentView {
                                blocksMouse: true
                                component: Button {
//                                    text: "Search"
//                                    action: function() {
//                                        var connection = new URL("http://catalogue.inovis.com/QRSGUI/widget/nrfColorCodes?ss={searchText}").openConnection();
//                                        connection.getInputStream();
//                                    }
                                }
                            }
                        ]
                    }
                ]
            }
        ]
    }
}