/*
 * NodeListView.fx
 *
 * Created on 2009-jul-23, 20:04:46
 */

package se.pmdit.screenshotfx.control;


import javafx.scene.Node;

import javafx.scene.CustomNode;



import javafx.scene.control.ScrollBar;
import javafx.scene.layout.ClipView;

import javafx.scene.Group;


import javafx.scene.Scene;
import javafx.stage.Stage;
import javafx.scene.paint.Color;

import javafx.scene.shape.Circle;

import javafx.scene.input.MouseEvent;


import javafx.scene.layout.VBox;
import javafx.scene.shape.Rectangle;

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
    
    var previouslySelected: ListItem;
    var scrollValue: Number = 0;
    var wrappedNodes: ListItem[] = [];

    public function add(node: Node, selectNode: Boolean): Void {
        var item = add(node);
        if(selectNode) {
            select(item);
        }
    }

    public function add(node: Node): ListItem {
        var item: ListItem;

        if(node instanceof ListItem) {
            item = node as ListItem;
            item.width = width;     // TODO: Hmmm... might not be the best idea...
            item.onMouseClicked = function(e: MouseEvent) {
                select(item);
            }
        }
        else {
            item = ListItem {
                node: node
                width: bind width
                onMouseClicked: function(e: MouseEvent) {
                    select(item);
                }
            };
        }

        insert item before wrappedNodes[0];
        return item;
    }

    public function remove(item: ListItem): Void {
        var index = indexofItem(item);

        scrollValue = 0;    // TODO: scroll per item instead of back to 0
        delete item from wrappedNodes;

        //println("index: {index}");
        if(sizeof wrappedNodes > 0) {
            if(index > 0) index -= 1;
            select(wrappedNodes[index]);
        }
        else {
            //select(null); // TODO: needed?
        }


    }

    public function removeSelected(): ListItem {
        var item = selected;
        remove(item);
        item.removed(); // notify item
        return item;
    }

    var contentGroup: Group;
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
        delete item from wrappedNodes;
        insert item before wrappedNodes[toPosition];

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

    override public function create(): Node {
        return Group {
            content: [
                clipView = ClipView {
                    width: bind width
                    height: bind height
                    pannable: false
                    clipY: bind scrollValue
                    node: contentGroup = VBox {
                        spacing: bind spacing
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

public function run() {
    var listView: NodeListView = NodeListView {
        width: 300
        height: 200
    };

    listView.add(
    Rectangle {
        width: 140, height: 90
        fill: Color.BLACK
    }


    );

    return Stage {
        scene: Scene {
            width: 400
            height: 300
            content: [
                Circle {
                    centerX: 100, centerY: 100
                    radius: 40
                    fill: Color.BLACK
                }
                listView
            ]
        }
    }
}

