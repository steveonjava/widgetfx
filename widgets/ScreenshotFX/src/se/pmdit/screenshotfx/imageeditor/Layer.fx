/*
 * Layer.fx
 *
 * Created on 2009-jul-22, 01:44:20
 */

// <editor-fold defaultstate="collapsed" desc="imports...">

package se.pmdit.screenshotfx.imageeditor;

import javafx.scene.CustomNode;
import javafx.scene.Node;
import javafx.scene.Group;
import se.pmdit.screenshotfx.control.ListItemListener;
import javafx.scene.image.ImageView;
import javafx.scene.shape.Rectangle;
import javafx.scene.paint.Color;


import javafx.geometry.Bounds;
// </editor-fold>

/**
 * @author pmd
 */

public class Layer extends CustomNode, ListItemListener {

    public var x: Number = 0;
    public var y: Number = 0;
    public var width: Number;
    public var height: Number;
    public var content: Node[];

    var contentGroup = Group {
        content: bind content
    };
    var thumbnailGroup = Group {};
    var background: Rectangle = Rectangle {
        width: width
        height: height
        fill: Color.WHITE
        opacity: 0.8
        visible: false
    };

    public function add(n: Node[]) {
        for(node in n) {
            insert node into content;
        }

        updateThumbnail();
    }

    public function remove(node: Node) {
        delete node from content;
    }

    public function updateThumbnail(): Void {
        if(width > 0 and height > 0 and visible) {
            background.visible = true;
            var bi = ImageEditor.captureImage(this, x, y, width, height);
            background.visible = false;
            thumbnailGroup.content = ImageView { image: ImageEditor.createThumbnail(bi, 150, 120) };
        }
    }

    public function clear() {
        delete content;
    }

    init {
        hasThumbnail = true;
        thumbnail = thumbnailGroup;
        updateThumbnail();
    }

    override public function create(): Node {
        return Group {
            content: [
                background,
                contentGroup
            ]
        }
    }

}
