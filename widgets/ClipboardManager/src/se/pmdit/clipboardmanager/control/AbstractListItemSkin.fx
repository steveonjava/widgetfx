/*
 * ListItemSkin.fx
 *
 * Created on 2009-aug-22, 01:26:58
 */

package se.pmdit.clipboardmanager.control;

import javafx.scene.control.Skin;

import javafx.scene.paint.Color;

import javafx.scene.input.MouseEvent;
import javafx.scene.shape.Rectangle;


import javafx.scene.Group;

import javafx.scene.Node;


import org.jfxtras.scene.util.BoundsPainter;

import javafx.scene.layout.LayoutInfo;

import javafx.geometry.VPos;




/**
 * @author pmd
 */

public abstract class AbstractListItemSkin extends Skin {

  public var width: Number = 0;
  public var height: Number = 0;
  public var margin: Number = 3;
  protected var listItemControl: ListItem = bind control as ListItem;
  protected var listItemBehavior: ListItemBehavior = bind behavior as ListItemBehavior;

  var highlightBorderColor: Color = Color.LIGHTGRAY;
  var highlightBackgroundColor: Color = Color.WHITE;
  var normalBorderColor: Color = Color.GRAY;
  var normalBackgroundColor: Color = Color.LIGHTGRAY;
  protected var borderColor: Color = normalBorderColor;
  protected var backgroundColor: Color = normalBackgroundColor;

  protected var contentBackground: Rectangle = Rectangle {
    width: bind if(width > 0) width else contentGroup.layoutBounds.width + (margin * 2);
    height: bind if(height > 0) height else contentGroup.layoutBounds.height + (margin * 2);
    fill: bind backgroundColor //Color.TRANSPARENT
    onMouseEntered: function(e: MouseEvent) {
      highlight(true);
    }
    onMouseExited: function(e: MouseEvent) {
      highlight(false);
    }
  } // TODO: test on replace { p(); }

//  function p(): Void {
//    println("height={height}, contentGroup.layoutBounds.height={contentGroup.layoutBounds.height}, contentBackground.height={contentBackground.height}, node.layoutBounds.height={node.layoutBounds.height}");
//    println("contentGroup.boundsInParent.height={contentGroup.boundsInParent.height}, contentBackground.boundsInParent.height={contentBackground.boundsInParent.height}, node.boundsInParent.height={node.boundsInParent.height}");
//  }

  var contentGroup: Group = Group {
    layoutX: bind margin
    layoutY: bind (contentBackground.height - 2 - contentGroup.layoutBounds.height) / 2
    content: bind content
  };
  public var content: Node[];

  init {
    node = //BoundsPainter { targetNode:
      Group {
      content: [
        //BoundsPainter { targetNode:
        contentBackground,
        //},
        //BoundsPainter { targetNode:
          contentGroup
        //}
      ]
    } //}
  }

  public function onContentChanged(content: Object): Void {
    listItemBehavior.onContentChanged();
  } 

  public function highlight(active: Boolean): Void {
    if(active) {
      borderColor = highlightBorderColor;
      backgroundColor = highlightBackgroundColor;
    }
    else {
      borderColor = normalBorderColor;
      backgroundColor = normalBackgroundColor;
    }
  }

  override public function contains(localX: Number, localY: Number): Boolean {
    return node.contains(localX, localY);
  }

  override public function intersects(localX: Number, localY: Number, localWidth: Number, localHeight: Number): Boolean {
    return node.intersects(localX, localY, localWidth, localHeight);
  }


}
