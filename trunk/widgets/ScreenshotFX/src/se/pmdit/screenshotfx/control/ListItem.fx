/*
 * ListItem.fx
 *
 * Created on 2009-jul-23, 22:45:42
 */
 
// <editor-fold defaultstate="collapsed" desc="imports...">

package se.pmdit.screenshotfx.control;

import javafx.scene.CustomNode;
import javafx.scene.Node;
import javafx.scene.Group;
import javafx.scene.input.MouseEvent;
import javafx.scene.paint.Color;
import javafx.scene.shape.Rectangle;
import se.pmdit.screenshotfx.control.ListItemListener;
import org.jfxtras.scene.border.SoftBevelBorder;

import javafx.scene.layout.VBox;
import javafx.scene.image.ImageView;

import javafx.scene.image.Image;
// </editor-fold>

/**
 * @author pmd
 */

public class ListItem extends CustomNode {

    public var width: Number = 100;
    public var selected: Boolean on replace {
        if(nodeIsListItemAware) {
            listItemAwareNode.onChangeSelected(selected);
        }
    };
    public var enabled: Boolean = true on replace {
        if(nodeIsListItemAware) {
            listItemAwareNode.onChangeEnabled(enabled);
        }
    };
    public-init var node: Node on replace {
        if(node instanceof ListItemListener) {
            nodeIsListItemAware = true;
            listItemAwareNode = node as ListItemListener;
        }
        else {  // For the future, if the node can be changed...
            nodeIsListItemAware = false;
            listItemAwareNode = null;
        }

        updateThumbnail();
    };

    var nodeIsListItemAware: Boolean;
    var listItemAwareNode: ListItemListener;

    public function moved(toPosition: Integer, fromPosition: Integer): Void {
        if(nodeIsListItemAware) {
            listItemAwareNode.onMove(toPosition, fromPosition);
        }

    }

    public function removed(): Void {
        println("item.removed");
        if(nodeIsListItemAware) {
            listItemAwareNode.onRemoved(node);
        }

    }

    var thumbnail: Node;

    public function updateThumbnail(): Void {
        if(nodeIsListItemAware and listItemAwareNode.hasThumbnail) {
            thumbnail = listItemAwareNode.thumbnail;
        }
        else {
            thumbnail = node;
        };
    }

    // TODO: Should of course be skinned...
    var baseColorLight2 = Color.web("#6a615c");
    var baseColorLight = Color.web("#4a413c");
    var baseColorDark = Color.web("#2a211c");
    var baseColor = Color.web("#3a312c");

    override public function create(): Node {
        return SoftBevelBorder {
            borderWidth: 1
            borderColor: baseColorLight
            raised: bind not selected
            node: Group {
                content: [
                    Rectangle {
                        x: bind thumbnail.layoutBounds.minX - 33     // TODO: fix hardcoded...
                        y: bind thumbnail.layoutBounds.minY - 3
                        width: bind thumbnail.layoutBounds.width + 36
                        height: bind thumbnail.layoutBounds.height + 6
                        fill: baseColor
                        onMouseClicked: function(e: MouseEvent) {
                            selected = true;
                        }
                    },
                    VBox {
                        translateX: -27 // TODO: fix hardcoded...
                        translateY: 3
                        content: [
                            ImageView {
                                opacity: bind if(selected) 1 else 0.3
                                image: bind if(selected) Image { url: "{__DIR__}lightbulb.png" }
                                        else Image { url: "{__DIR__}lightbulb_off.png" }
                            }
                            ImageView {
                                opacity: bind if(enabled) 1 else 0.3
                                image: Image { url: "{__DIR__}eye.png" }
                                onMouseClicked: function(e: MouseEvent) {
                                    enabled = not enabled;
                                }
                            }
                        ]
                    },
                    thumbnail
                ]
            }
        }
    }

}
