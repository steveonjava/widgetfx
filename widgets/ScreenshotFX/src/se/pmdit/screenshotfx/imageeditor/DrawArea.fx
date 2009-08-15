/*
 * DrawArea.fx
 *
 * Created on 2009-jul-04, 00:43:41
 */
 
// <editor-fold defaultstate="collapsed" desc="imports...">
package se.pmdit.screenshotfx.imageeditor;

import javafx.scene.CustomNode;

import javafx.scene.Node;

import javafx.scene.Group;

import javafx.scene.input.MouseEvent;
import javafx.scene.paint.Color;
import javafx.scene.shape.Circle;
import javafx.scene.shape.LineTo;
import javafx.scene.shape.MoveTo;
import javafx.scene.shape.Path;
import javafx.scene.shape.Rectangle;
import javafx.scene.shape.StrokeLineCap;
import javafx.scene.shape.StrokeLineJoin;
// </editor-fold>

/**
 * @author pmd
 */
public class DrawArea extends CustomNode {

    public var drawTarget: Layer;
    public var width: Number;
    public var height: Number;
    public var drawColor: Color = Color.BLACK;
    public var brushSize: Number = 5.0;

    var lines = Group {};
    var mouseX: Number = 1.0;
    var mouseY: Number = 1.0;
    var currentPath: Path;
    var pointerOnDrawArea: Boolean = true;

    function press(e:MouseEvent): Void {
        mouseX = if(e.x < -brushSize) -brushSize else if (e.x > width + brushSize) width + brushSize else e.x;
        mouseY = if(e.y < -brushSize) -brushSize else if (e.y > height) height else e.y;
        insert currentPath = Path{
            elements: MoveTo{ x: mouseX, y: mouseY }
            strokeWidth: brushSize
            strokeLineCap: StrokeLineCap.ROUND
            strokeLineJoin: StrokeLineJoin.ROUND
            stroke: drawColor
        } into lines.content;
    }

    function drag(e:MouseEvent): Void {
        mouseX = if(e.x < -brushSize) -brushSize else if (e.x > width + brushSize) width + brushSize else e.x;
        mouseY = if(e.y < -brushSize) -brushSize else if (e.y > height + brushSize) height + brushSize else e.y;
        insert LineTo{ x: mouseX, y: mouseY } into currentPath.elements;
    };

    function release(e:MouseEvent): Void {
        mouseX = if(e.x < 0) 0 else if (e.x > width) width else e.x;
        mouseY = if(e.y < 0) 0 else if (e.y > height) height else e.y;
        insert LineTo{ x: mouseX, y: mouseY } into currentPath.elements;

        var nodes = lines.content;

        clear();
        drawTarget.add(Group {
            //layoutX: -drawTarget.layoutX    // TODO: Annoying... need to get a grip on the coordinates
            //layoutY: -drawTarget.layoutY
            content: nodes
        });

        currentPath = null;
    };

    function move(e:MouseEvent): Void {
        mouseX = e.x;
        mouseY = e.y;
    };

    function clear() {
        delete lines.content;
    }

    override public function create(): Node {
        Group {
            content: [
                Rectangle {
                    width: bind width
                    height: bind height
                    fill: Color.TRANSPARENT
                    blocksMouse: true;
                    disable: bind disable
                    onMousePressed: press;
                    onMouseDragged: drag;
                    onMouseReleased: release;
                    onMouseMoved: move;
                    onMouseEntered: function(e: MouseEvent) {
                        pointerOnDrawArea = true;
                    }
                    onMouseExited: function(e: MouseEvent) {
                        pointerOnDrawArea = false;
                    }
                }
                Circle {
                    fill: bind drawColor
                    radius: bind brushSize / 2
                    translateX: bind mouseX
                    translateY: bind mouseY
                    visible: bind not disabled and pointerOnDrawArea
                },
                lines
            ]
        };
    }

}
