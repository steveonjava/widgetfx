/*
 * Background.fx
 *
 * Created on 2009-feb-12, 23:14:36
 */

package se.pmdit.screenshotfx.imageeditor;

import javafx.scene.CustomNode;
import javafx.scene.Group;
import javafx.scene.Node;
import javafx.scene.paint.Color;
import javafx.scene.paint.LinearGradient;
import javafx.scene.paint.Stop;
import javafx.scene.shape.*;

/**
 * @author pmd
 */
public class BlueBackground extends CustomNode {

    public var x: Number = 0;
    public var y: Number = 0;
    public var width: Number = 100;
    public var height: Number = 100;
    //    public var backgroundColor: Color = Color.web("#B8CEE0");
    //    public var backgroundDecoration1Color: Color = Color.web("#6A7483");
    //    public var backgroundDecoration2Color: Color = Color.web("#3E5363");
    public var backgroundColor: Color = Color.web("#B8CEE0");
    public var backgroundDecoration1Color: Color = Color.web("#0588BC");
    public var backgroundDecoration2Color: Color = Color.web("#627894");
    var decorationWidth: Number = bind width * 0.5;
    var decorationHeight: Number = bind height * 0.2;
    var decoration1Scale: Number[] = [ 1, 1.5 ];
    var decoration2Scale: Number[] = [ 1, 1 ];
    var curve: Number = 3;
    //    var clipping: Rectangle = Rectangle {
    //        x: bind x;
    //        y: bind y;
    //        width: bind width;
    //        height: bind height;
    //    }

    override public function create(): Node {
        return Group {
            //clip: clipping
            content: [
                Rectangle {
                    x: bind x;
                    y: bind y;
                    width: bind width;
                    height: bind height;
                    fill: LinearGradient {
                        startX: 0.5,
                        startY: 0.0,
                        endX: 0.5,
                        endY: 1.0
                        proportional: true
                        stops: [
                            Stop {
                                offset: 0.0
                                color: Color.web("#CAE4F1");
                            },
                            Stop {
                                offset: 1.0
                                color: Color.web("#00578A");
                            }
                        ]
                    }
                    cache: true
                },
                Path {
                    translateX: bind ((decoration1Scale[0] * decorationWidth) - decorationWidth) / 2
                    translateY: bind ((decoration1Scale[1] * decorationHeight) - decorationHeight) / 2
                    scaleX: decoration1Scale[0]
                    scaleY: decoration1Scale[1]
                    stroke: null
                    //fill: bind backgroundDecoration1Color
                    fill: LinearGradient {
                        startX: 0.5,
                        startY: 0.0,
                        endX: 0.5,
                        endY: 1.0
                        proportional: true
                        stops: [
                            Stop {
                                offset: 0.0
                                color: Color.web("#CAE4F1");
                            },
                            Stop {
                                offset: 1.0
                                color: backgroundDecoration1Color //Color.web("#00578A");
                            }
                        ]
                    }
                    cache: true
                    elements: [
                        MoveTo {
                            x: 0
                            y: 0
                        },
                        HLineTo {
                            x: bind decorationWidth
                        },
                        QuadCurveTo {
                            x: 0
                            y: bind decorationHeight
                            controlX: bind decorationWidth / curve
                            controlY: bind decorationHeight / curve
                        },
                        LineTo {
                            x: 0
                            y: 0
                        },
                    ]
                },
                Path {
                    translateX: bind ((decoration2Scale[0] * decorationWidth) - decorationWidth) / 2
                    translateY: bind ((decoration2Scale[1] * decorationHeight) - decorationHeight) / 2
                    scaleX: decoration2Scale[0]
                    scaleY: decoration2Scale[1]
                    stroke: null
                    //fill: bind backgroundDecoration2Color
                    fill: LinearGradient {
                        startX: 0.5,
                        startY: 0.0,
                        endX: 0.5,
                        endY: 1.0
                        proportional: true
                        stops: [
                            Stop {
                                offset: 0.0
                                color: Color.web("#CAE4F1");
                            },
                            Stop {
                                offset: 1.0
                                color: backgroundDecoration2Color //Color.web("#00578A");
                            }
                        ]
                    }
                    cache: true
                    elements: [
                        MoveTo {
                            x: 0
                            y: 0
                        },
                        HLineTo {
                            x: bind decorationWidth
                        },
                        QuadCurveTo {
                            x: 0
                            y: bind decorationHeight
                            controlX: bind decorationWidth / curve
                            controlY: bind decorationHeight / curve
                        },
                        LineTo {
                            x: 0
                            y: 0
                        },
                    ]
                }
//                Ellipse {
//                    centerX: 126,
//                    centerY: 135
//                    radiusX: 80,
//                    radiusY: 40
//                    scaleX: 4
//                    scaleY: 3
//                    rotate: -35
//                    fill: Color.web("#A0A0A0", 1.0);
//                },
//                Ellipse {
//                    centerX: 126,
//                    centerY: 135
//                    radiusX: 80,
//                    radiusY: 40
//                    scaleX: 3
//                    scaleY: 2
//                    rotate: -50
//                    fill: Color.web("#F0F0F0", 1.0);
//                }
            ]
        }
    }

}
