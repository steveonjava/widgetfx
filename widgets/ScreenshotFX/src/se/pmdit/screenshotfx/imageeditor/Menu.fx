/*
 * Menu.fx
 *
 * Created on 2009-jul-02, 20:32:45
 */

package se.pmdit.screenshotfx.imageeditor;

import javafx.scene.layout.Container;
import javafx.scene.image.Image;
import javafx.scene.image.ImageView;
import javafx.scene.input.MouseEvent;
import javafx.scene.control.Button;
import javafx.scene.Node;
import javafx.geometry.HPos;
import javafx.scene.layout.Flow;
import javafx.scene.paint.Color;
import javafx.scene.shape.Rectangle;
import javafx.scene.CustomNode;

import javafx.scene.layout.VBox;

/**
 * @author pmd
 */
public class Menu extends CustomNode {

//    var appPanel: Node = Flow {
//        hgap: 10
//        nodeHPos: HPos.CENTER
//        content: [
//            // Save
//            Button {
//                graphic: ImageView {
//                    image: Image {
//                        url: "{__DIR__}icons/document-save.png"
//                    }
//                }
//                onMouseClicked: function(e: MouseEvent) {
//                    onMenuAction(MenuAction.SAVE);
//                }
//            }
//
//            // Exit
//            Button {
//                graphic: ImageView {
//                    image: Image {
//                        url: "{__DIR__}icons/system-log-out.png"
//                    }
//                }
//                onMouseClicked: function(e: MouseEvent) {
//                    onMenuAction(MenuAction.EXIT);
//                }
//            }
//        ]
//    };

    public var onAddLayer: function();
    public var onDeleteActiveLayer: function();
    public var onSelectLayer: function(:Layer);
    public var menuPanels: MenuPanel[] on replace {
        calculateMinMenuPanelWidth();
    };

    //var minMenuPanelWidth: Number = 0;
    var pos = Point {};
    var diff = Point {};

    function calculateMinMenuPanelWidth() {
        var minMenuPanelWidth: Number = 0;
        for(panel in menuPanels) {
            if(panel.layoutBounds.width > minMenuPanelWidth) {
                minMenuPanelWidth = panel.layoutBounds.width;
            }
        }

        for(panel in menuPanels) {
            panel.minWidth = minMenuPanelWidth;
        }
    }

    postinit {
        calculateMinMenuPanelWidth();
    }

    var contentWidth: Number = bind contentGroup.boundsInParent.maxX + (marginX * 2);
    var contentHeight: Number = bind contentGroup.boundsInParent.maxY + (marginY * 2);
    var contentGroup: Node;
    public var marginX: Number = 0;
    public var marginY: Number = 5;

    override public function create(): Node {
        Container {
            translateX: bind pos.x;
            translateY: bind pos.y;
            blocksMouse: true

            onMousePressed: function(e: MouseEvent) {
                diff.x = e.x;
                diff.y = e.y;
            }
            onMouseDragged: function(e: MouseEvent) {
                pos.x += e.x - diff.x;
                pos.y += e.y - diff.y;
            }

            content: [
                Rectangle {
                    id: "menuBackground"
                    y: bind -marginY
                    width: bind contentWidth
                    height: bind contentHeight
                    arcWidth: bind marginY * 2
                    arcHeight: bind marginY * 2
                    fill: Color.web("#3a312c")
                }
                contentGroup = VBox {
                    //vertical: true
                    //vgap: 0
                    content: bind menuPanels
                }
            ]
        }

    }
}
