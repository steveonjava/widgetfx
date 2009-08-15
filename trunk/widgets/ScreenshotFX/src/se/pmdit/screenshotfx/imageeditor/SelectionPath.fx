/*
 * MovablePath.fx
 *
 * Created on 2009-jun-27, 01:49:48
 */

package se.pmdit.screenshotfx.imageeditor;

import javafx.scene.CustomNode;
import javafx.scene.Group;
import javafx.scene.Node;
import javafx.scene.input.MouseEvent;
import javafx.scene.paint.Color;
import javafx.scene.shape.ClosePath;
import javafx.scene.shape.LineTo;
import javafx.scene.shape.MoveTo;
import javafx.scene.shape.Path;
import javafx.scene.shape.Circle;
import javafx.scene.shape.Shape;
import javafx.scene.shape.Rectangle;
import javafx.animation.KeyFrame;
import javafx.animation.Timeline;

/**
 * @author pmd
 */

public class SelectionPath extends CustomNode {

    public var width: Number on replace { recalculate(); };
    public var height: Number on replace { recalculate(); };
    var x: Number = 0;
    var y: Number = 0;
    public var defaultOpacity = 0.0;
    public var selectedOpacity = 0.6;
    public var fill = false;
    public var fillColor = Color.BLACK;
    public var freeMovement: Boolean = true;
    public var enabled: Boolean = true;

    public-read var shape: Shape;

    public var animate: Boolean = false;
    var animating: Boolean = false on replace {
        // TODO: Will be times when the animating isn't started... but good enough for now
        if(animating and animate and sizeof points > 1) timer.play() else timer.pause();
    };
    var lineOffset: Number;
    var timer = Timeline {
        repeatCount: Timeline.INDEFINITE
        keyFrames: [
            KeyFrame { time: 0s values: lineOffset => 0 }
            KeyFrame { time: 1s values: lineOffset => 10 }
        ]
        framerate: 10
    };

    var hintsEnabled: Boolean = bind (insidePathBoundary or insideHintBoundary) on replace {
        if(hintsEnabled) {
            polyOpacity = selectedOpacity;
        }
        else {
            polyOpacity = defaultOpacity;
        }
    };
    var insidePathBoundary: Boolean = false;
    var insideHintBoundary: Boolean = false;
    var polyOpacity = defaultOpacity;
    var diff = Point {};
    public var points: Point[] = [ Point {} ];
    var center = Point {};

    public function getCopyAsPath(setLayout: Boolean): Path {
        var p = getCopyAsPath();
        if(setLayout) {
            p.layoutX = x;
            p.layoutY = y;
        }
        return p;
    }

    public function getCopyAsPath(): Path {
        return Path {
            stroke: Color.TRANSPARENT
            elements: [
                for(point in points) {
                    if(indexof point == 0) {
                        MoveTo { x: point.x, y: point.y };
                    }
                    else {
                        LineTo { x: point.x, y: point.y };
                    }
                }

                if(sizeof points > 1) {
                    ClosePath {}
                }
                else { [] }
            ]

        }
    }

    public function add(point: Point): Void {
        insert point into points;
    }

    public function clear(): Void {
        x = 0;
        y = 0;
        points = [ Point {} ];
    }

    init {
        recalculate();
        animating = true;
    }

    function recalculate(): Void {
        for(p in points) {
            if(p.x > width) {
                p.x = width;
            }

            if(p.y > height) {
                p.y = height;
            }
        }

        center.moveToCenter(points);
    }

    public function drawPath() {
        enabled = true;
        background.visible = true;
    }

    function endDrawPath() {
        background.visible = false;
        onDrawPathDone();
    }

    public var onDrawPathDone: function();

    function createPath(posX: Number, posY: Number) {
        x = posX;
        y = posY;

        points = [ 
            Point { x: -1, y: -1 },
            Point { x:  1, y: -1 },
            Point { x:  1, y:  1 },
            Point { x: -1, y:  1 }
        ];
    }

    var background: Rectangle;
    var showPath: Boolean = true;
    var scaleTo: Point;
    var scaleStart: Point;
    var scaleFrom: Point;

    function dragScale(dragX: Number, dragY: Number): Void {
        scaleTo.x = scaleStart.x + dragX;
        scaleTo.y = scaleStart.y + dragY;

        if(scaleTo.x > width - x) scaleTo.x = width - x;
        if(scaleTo.y > height - y) scaleTo.y = height - y;

        Point.scaleToPoint(points, points[0], points[2], scaleTo);
        recalculate();
    }

    override public function create(): Node {
        Group {
            visible: bind enabled
            content: [
                Group {
                    content: bind [
                        background = Rectangle {
                            width: bind width
                            height: bind height
                            fill: Color.TRANSPARENT
                            blocksMouse: true
                            visible: false
                            onMousePressed: function(e: MouseEvent) {
                                createPath(e.x, e.y);
                                scaleTo = points[2].getCopy();
                                scaleStart = points[2].getCopy();
                                animating = false;
                            }
                            onMouseDragged: function(e: MouseEvent) {
                                dragScale(e.dragX, e.dragY);
                            }
                            onMouseReleased: function(e: MouseEvent) {
                                endDrawPath();
                                animating = true;
                            }
                        },
                        Circle {    // TODO: Action Icon
                            translateX: bind x
                            translateY: bind y
                            centerX: bind center.x
                            centerY: bind center.y
                            radius: 10
                            fill: Color.BLACK
                            stroke: Color.WHITE
                            strokeWidth: 2
                            opacity: bind polyOpacity
                            blocksMouse: true
                            visible: bind (sizeof points >= 3)

                            onMouseEntered: function(e: MouseEvent) {
                                insideHintBoundary = true;
                            }
                            onMouseExited: function(e: MouseEvent) {
                                insideHintBoundary = false;
                            }
                            onMousePressed: function(e: MouseEvent) {
                                diff.x = e.x;
                                diff.y = e.y;
                            }
                            onMouseDragged: function(e: MouseEvent) {
                                x += e.x - diff.x;
                                y += e.y - diff.y;

                                if(x > width) x = width;
                                if(y > height) y = height;
                            }
                        }
                        for(point in points) {
                            Circle {
                                translateX: bind x
                                translateY: bind y
                                centerX: bind point.x
                                centerY: bind point.y
                                radius: 4
                                fill: Color.BLACK
                                stroke: Color.WHITE
                                strokeWidth: 1
                                opacity: bind polyOpacity
                                blocksMouse: true
                                visible: (indexof point == 2)   // TODO: fix the others

                                onMouseEntered: function(e: MouseEvent) {
                                    insideHintBoundary = true;
                                }
                                onMouseExited: function(e: MouseEvent) {
                                    insideHintBoundary = false;
                                }
                                onMousePressed: function(e: MouseEvent) {
                                    scaleTo = point.getCopy();
                                    scaleStart = point.getCopy();
                                    scaleFrom = point.getFurthestAway(points).getCopy();
                                    animating = false;
                                }
                                onMouseDragged: function(e: MouseEvent) {
                                    dragScale(e.dragX, e.dragY);
                                }
                                onMouseReleased: function(e: MouseEvent) {
                                    animating = true;
                                }
                            }
                        }
                    ]
                }
                Group {
                    content: [
                        shape = Path {
                            fill: if(fill) fillColor else Color.TRANSPARENT;
                            translateX: bind x;
                            translateY: bind y;
                            strokeDashArray: [ 3, 3 ]
                            strokeDashOffset: bind lineOffset
                            visible: showPath
                            elements: bind [
                                for(point in points) {
                                    if(indexof point == 0) {
                                        MoveTo { x: bind point.x, y: bind point.y };
                                    }
                                    else {
                                        LineTo { x: bind point.x, y: bind point.y };
                                    }
                                }

                                if(sizeof points > 1) {
                                    ClosePath {}
                                }
                                else { [] }
                            ]
                            onMouseEntered: function(e: MouseEvent) {
                                insidePathBoundary = true;
                            }
                            onMouseExited: function(e: MouseEvent) {
                                insidePathBoundary = false;
                            }
                        }
                    ]
                }
            ]
        }
    }

}
