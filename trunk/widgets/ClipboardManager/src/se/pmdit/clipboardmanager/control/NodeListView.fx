/*
 * NodeListView.fx
 *
 * Created on 2009-jul-23, 20:04:46
 */

// <editor-fold defaultstate="collapsed" desc="imports...">
package se.pmdit.clipboardmanager.control;


import javafx.scene.Node;

import javafx.scene.CustomNode;



import javafx.scene.control.ScrollBar;
import javafx.scene.layout.ClipView;

import javafx.scene.Group;




import javafx.scene.input.MouseEvent;















import javafx.scene.layout.VBox;

// </editor-fold>

/**
 * @author pmd
 */

public class NodeListView extends CustomNode {

    //public var content: Node[] = [];
    public var selected: ListItem on replace {
        selected.selected = true;
    };
    public var width: Number;
    public var height: Number;
    public var spacing: Number = 2;
    
    public-read var size: Integer = bind sizeof wrappedNodes;
    public-read var hScrolling: Boolean = false;  // TODO: add optional hscroll
    
    var previouslySelected: ListItem;
    var scrollValue: Number = 0;
    var wrappedNodes: ListItem[] = [];
    //var wrappedNodes: Node[] = [];

//    public function add(node: Node, selectNode: Boolean): Void {
//        var item = add(node);
//        if(selectNode) {
//            select(item);
//        }
//    }

//    public function add(object: Object): ListItem {
//      var item: ListItem = ListItem {
//          content: object
//          width: width / 2
//          //height: 20
//      };
//
//      return add(item);
//    }

    public function add(item: ListItem): ListItem {
      if(not hScrolling) {
        item.width = width;     // TODO: Hmmm... might not be the best idea...
      }

      //item.height = 0;

      item.onMouseClicked = function(e: MouseEvent) {
          select(item);
      }

      //insert BoundsPainter { targetNode: item } before wrappedNodes[0];
      //insert Group { content: item } before wrappedNodes[0];
      insert item before wrappedNodes[0];
      //println("item: {item.height}, {item.skin.node.layoutBounds.height}, {item.skin.node.boundsInLocal.height}, {item.skin.node.boundsInParent.height}");
      //insert Circle { centerX: 10, centerY: 10, radius: 10, fill: Color.BLACK } before wrappedNodes[0];
      contentGroup.layout();
      return item;
    }

    public function remove(item: ListItem): Void {
        var index = indexofItem(item);

        scrollValue = 0;    // TODO: scroll per item instead of back to 0
        delete item from wrappedNodes;

        if(sizeof wrappedNodes > 0) {
            if(index > 0) index -= 1;
            // TODO: test: select(wrappedNodes[index]);
        }
        else {
            //select(null); // TODO: needed?
        }
    }

    public function remove(index: Integer): Void {
      var item = wrappedNodes[index];
      if(item != null) {
        remove(item);
      }
    }

    public function removeSelected(): ListItem {
        var item = selected;
        remove(item);
        item.removed(); // notify item
        return item;
    }

    var clipView: ClipView;
    var verticalScroll: ScrollBar = ScrollBar {
        min: 0
        max: bind if(contentGroup.boundsInParent.height >= clipView.height) contentGroup.boundsInParent.height - clipView.height else 1
        height: bind height
        disable: bind not (contentGroup.boundsInParent.height >= clipView.height)
        translateX: bind clipView.layoutBounds.maxX
        value: bind scrollValue with inverse
        vertical: true
        opacity: bind if(contentGroup.boundsInParent.height >= clipView.height) 1 else 0.2
    }

    function select(item: ListItem) {
        if(not item.equals(selected)) {
            previouslySelected = selected;
            if(previouslySelected != null) {
                previouslySelected.selected = false;
            }
            selected = item;
        }
    }

    function move(item: ListItem, toPosition: Integer, fromPosition: Integer) {
//        delete item from wrappedNodes;
//        insert item before wrappedNodes[toPosition];

        item.moved(toPosition, fromPosition);   // notify item
    }

    public function move(item: ListItem, toPosition: Integer) {
        move(item, toPosition, indexofItem(item));
    }

    public function moveDirection(item: ListItem, direction: Integer) {
        var oldIndex = indexofItem(item);
        var newIndex = oldIndex + direction;
        if(newIndex < 0) newIndex = 0
        else if(newIndex > sizeof wrappedNodes) newIndex = sizeof wrappedNodes;

        move(item, newIndex, oldIndex);
    }

    public function indexofItem(item: ListItem): Integer {
        var index = 0;
        for(node in wrappedNodes where node == item) {
            index = indexof node;
        }
        return index;
    }

    var contentGroup: VBox;
    override public function create(): Node {
        return Group {
            content: [
                clipView = ClipView {
                    width: bind width
                    height: bind height
                    pannable: false
                    clipY: bind scrollValue
                    node: contentGroup = VBox {
                        //spacing: bind spacing
                        //vertical: true
                        //spacing: 10
                        //height: 400
                        content: bind wrappedNodes

                    }
                    onMouseWheelMoved: function(e: MouseEvent) {
                        var value = scrollValue + (e.wheelRotation * 5);
                        if(value >= verticalScroll.max) {
                            scrollValue = verticalScroll.max;
                        }
                        else if(value <= verticalScroll.min) {
                            scrollValue = verticalScroll.min;
                        }
                        else {
                            scrollValue = value;
                        }
                    }
                },
                verticalScroll
            ]
        }
    }
}

//public function run() {
//    var listView: NodeListView = NodeListView {
//        width: 300
//        height: 200
//    };
//
//    listView.add(
//      Rectangle {
//          width: 140, height: 90
//          fill: Color.BLACK
//      }
//    );
//
//    return Stage {
//        scene: Scene {
//            width: 400
//            height: 300
//            content: [
//                Circle {
//                    centerX: 100, centerY: 100
//                    radius: 40
//                    fill: Color.BLACK
//                }
//                listView
//            ]
//        }
//    }
//}

