/*
 * InnerPanel.fx
 *
 * Created on 2009-jun-28, 01:21:36
 */

package se.pmdit.screenshotfx.imageeditor;

import javafx.scene.CustomNode;
import javafx.scene.Group;
import javafx.scene.Node;
import javafx.scene.input.MouseEvent;
import javafx.scene.paint.Color;
import javafx.scene.paint.LinearGradient;
import javafx.scene.paint.Stop;
import javafx.scene.shape.Rectangle;
import javafx.scene.text.Font;
import javafx.scene.text.FontWeight;
import javafx.scene.text.Text;
import javafx.scene.effect.DropShadow;
import javafx.scene.image.Image;
import javafx.scene.image.ImageView;

/**
 * @author pmd
 */

public class MenuPanel extends CustomNode {
    public var content: Node[] = [];
    public var title = "Title";
    public var margin: Number = 3;
    public var minWidth: Number = 0;
    public var minHeight: Number = 0;
    public var open: Boolean = true;

    public-read var width: Number = bind if(minWidth > contentWidth) minWidth else contentWidth;
    public-read var height: Number = bind if(minHeight > contentHeight) minHeight else contentHeight;
    
    var contentWidth: Number = bind contentGroup.layoutBounds.maxX + (margin * 2);
    var contentHeight: Number = bind contentGroup.layoutBounds.maxY + (margin * 2);

    var titelHeight: Number = 20;
    //var panelWidth = bind NumberUtils.max(contentGroup.layoutBounds.maxX, minWidth);
    var panelHeight = bind contentGroup.layoutBounds.maxY;
    var baseColor = Color.web("#3a312c");
    var baseColorLight = Color.web("#4a413c");
    var baseColorDark = Color.web("#2a211c");
    var titleColor = Color.web("#47453c");
    var titleColorLight = Color.web("#67655c");
    var titleColorDark = Color.web("#27251c");
    var panelGroup: Group;
    var contentGroup: Group;

    var wierdOffsetFix = 1; // Line 1px longer than rectangle?

    override public function create(): Node {
        // Inner collapsable panel
        panelGroup = Group {
            var panelPosY: Number = bind titelHeight;
            var background: Rectangle;

            content: [
                // Panel group
                Group {
                    visible: bind open;
                    //translateY: bind panelPosY / 2;
                    content: [
                        background = Rectangle {
                            //arcHeight: 15;
                            //arcWidth: 15;
                            width: bind width;
                            height: bind height + titelHeight;
                            fill: LinearGradient {
                                startX: 0.5
                                startY: 0.0
                                endX: 0.5
                                endY: 1
                                proportional: true
                                stops: [
                                    Stop {
                                        color : baseColorLight
                                        offset: 0.0
                                    },
                                    Stop {
                                        color : baseColor
                                        offset: 1.0
                                    },

                                ]
                            }
//                            effect: DropShadow {
//                                offsetX: 2
//                                offsetY: 2
//                                color: Color.BLACK
//                                radius: 5
//                            }
//                            effect: InnerShadow {
//                                choke: 0
//                                offsetY: 3
//                                radius: 4
//                                width: 0
//                                color: baseColorDark
//                            }
                        },
                        contentGroup = Group {
                            translateX: margin
                            translateY: bind titelHeight + margin
                            visible: bind open
                            content: content
                        }
                    ]
                }

                // Title group
                Group {
                    content: [
                        Rectangle {
                            x: 0, y: 0
                            width: bind width
                            height: bind titelHeight
                            fill: LinearGradient {
                                proportional: false
                                startX: 0.5
                                startY: 0.0
                                endX: 0.5
                                endY: 20
                                stops: [
                                    Stop {
                                        color : titleColor
                                        offset: 0.0
                                    },
                                    Stop {
                                        color : titleColorLight
                                        offset: 1.0
                                    },

                                ]
                            }
                        },
//                        Line {
//                            startX: 0, startY: 0
//                            endX: bind width - wierdOffsetFix, endY: 0
//                            strokeWidth: 1
//                            stroke: titleColorLight
//                        },
//                        Line {
//                            startX: 0, startY: bind titelHeight
//                            endX: bind width - wierdOffsetFix, endY: bind titelHeight
//                            strokeWidth: 1
//                            stroke: titleColorDark
//                        },
                        ImageView {
                            var img: Image;
                            x: 2
                            y: bind (titelHeight - img.height) / 2
                            image: img = Image {
                                url: "{__DIR__}icons/mail-send-receive.png"
                            }
                            onMouseClicked: function(e: MouseEvent) {
                                open = not open;
                            }
                        }
                        Text {
                            font: Font.font("Arial", FontWeight.BOLD, 14)
                            fill: Color.WHITESMOKE
                            x: bind titelHeight * 1.1
                            y: bind titelHeight * 0.75
                            content: bind title
                            effect: DropShadow {
                                offsetX: 1
                                offsetY: 1
                                color: bind titleColorDark
                                radius: 2
                            }
                        }
                    ]
                }
            ]
        }
    }

}
