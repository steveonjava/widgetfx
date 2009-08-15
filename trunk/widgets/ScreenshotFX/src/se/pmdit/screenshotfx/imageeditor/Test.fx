/*
 * Test.fx
 *
 * Created on 2009-jul-23, 02:12:30
 */

// <editor-fold defaultstate="collapsed" desc="imports...">

package se.pmdit.screenshotfx.imageeditor;

import javafx.stage.Stage;
import javafx.scene.Scene;
import javafx.scene.paint.Color;


import javafx.scene.Group;


import javafx.scene.shape.Rectangle;



import org.jfxtras.scene.layout.Grid;



import org.jfxtras.scene.layout.LayoutConstants.*;

import org.jfxtras.scene.layout.Cell;



import org.jfxtras.scene.layout.GridLayoutInfo;

import org.jfxtras.scene.util.BoundsPainter;
import org.jfxtras.scene.layout.ResizableVBox;
// </editor-fold>

/**
 * @author pmd
 */

//public class Test extends CustomNode {
//
//    override public function create(): Node {
//        return Group {
//            content: [
//            ]
//        }
//    }
//
//}

var layer1: Rectangle = Rectangle {
    width: 300
    height: 300
    fill: Color.BLUE
}

var layer2: Rectangle = Rectangle {
    width: 250
    height: 250
    fill: Color.GREEN
}

var clipping: Rectangle = Rectangle {
    layoutX: 50
    width: 50
    height: 50
    //fill: Color.GREEN
}

var layers: Group = Group {
    content: [
        layer1, layer2
    ]
    clip: clipping
}

var tools: Rectangle = Rectangle {
    width: 300
    height: 300
    fill: Color.RED
    opacity: 0.4
    visible: true
}

var sceneContent: Group;
var scene: Scene;

Stage {
    scene: scene = Scene {
        width: 400
        height: 400
        fill: Color.LIGHTGRAY
        content: [
            BoundsPainter { targetNode: Grid {
                width: bind scene.width - 10
                growColumns: [ 0, 1 ]

                rows: row([
                    Rectangle { width: 80, height: 80, fill: Color.RED }
                    Cell {
                        fill: HORIZONTAL
                        hgrow: ALWAYS
                        content: BoundsPainter { targetNode: ResizableVBox {
                            spacing: 3
                            nodeHPos: LEFT
                            layoutInfo: GridLayoutInfo { hgrow: ALWAYS, fill: HORIZONTAL }
                            content: [
                                Rectangle { width: 20, height: 20, fill: Color.BLUE, layoutInfo: GridLayoutInfo { hgrow: ALWAYS, fill: HORIZONTAL } }
                                Rectangle { width: 220, height: 20, fill: Color.GREEN },
                                Rectangle { width: 200, height: 20, fill: Color.YELLOW }
                            ]
                        }}
                    }
                ])
            }}


//            sceneContent = Group {
//                translateX: bind (scene.width - layers.boundsInLocal.width) / 2 - layers.boundsInLocal.minX
//                translateY: bind (scene.height - layers.boundsInLocal.height) / 2 - layers.boundsInLocal.minY
//                content: [
//                    layers,
//                    tools
//                ]
//            },
//            Label { text: bind "{layers.layoutX}" }
//            Label { text: bind "{layers.layoutBounds.width}, {layers.boundsInLocal.width}", translateY: 14 }
//            Label { text: bind "{layers.boundsInParent.minX}", translateY: 28 }
//            Label { text: bind "{layers.boundsInLocal.minX}", translateY: 42 }
//            MenuPanel {
//                translateX: 10
//                translateY: 10
//                title: "gradients"
//                content: [
//                    Rectangle {
//                        width: 100
//                        height: 100
//                        fill: LinearGradient {
//                            proportional: false
//                            startX: 0.5
//                            startY: 0.0
//                            endX: 0.5
//                            endY: 100
//                            stops: [
//                                Stop {
//                                    color: Color.BLUE
//                                    offset: 0.0
//                                },
//                                Stop {
//                                    color: Color.VIOLET
//                                    offset: 1.0
//                                },
//
//                            ]
//                        }
//                    },
//                    Rectangle {
//                        translateX: 100
//                        width: 100
//                        height: 100
//                        fill: LinearGradient {
//                            proportional: true
//                            startX: 0.5
//                            startY: 0.0
//                            endX: 0.5
//                            endY: 1
//                            stops: [
//                                Stop {
//                                    color: Color.BLACK
//                                    offset: 0.0
//                                },
//                                Stop {
//                                    color: Color.GREEN
//                                    offset: 0.8
//                                },
//
//                            ]
//                        }
//                    }
//                ]
//            }
        ]
    }
}
