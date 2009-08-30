/*
 * Test.fx
 *
 * Created on 2009-aug-22, 20:34:21
 */

package se.pmdit.clipboardmanager;

import javafx.stage.Stage;
import javafx.scene.Scene;
import org.jfxtras.scene.layout.Grid;
import org.jfxtras.scene.layout.Row;
import javafx.scene.image.ImageView;
import javafx.scene.image.Image;
import javafx.scene.control.Label;

import javafx.scene.input.MouseEvent;

import javafx.scene.Group;
import javafx.scene.shape.Rectangle;
import javafx.scene.paint.Color;

import org.jfxtras.scene.border.LineBorder;
import javafx.scene.control.Hyperlink;

import javafx.scene.layout.VBox;

/**
 * @author pmd
 */

var popupMenu: Group = Group {
  opacity: 0.9
  content: [
    LineBorder {
      thickness: 1
      lineColor: Color.LIGHTGRAY
      node: Rectangle {
        width: 140, height: 90
        fill: Color.WHITE
      }
    },
    VBox {
      content: [
        Hyperlink {
          text: "set in clipboard"
          action: function() {
            popupMenu.visible = false;
          }
        }
        Hyperlink {
          text: "edit"
          action: function() {
            popupMenu.visible = false;
          }
        }
      ]
    }
  ]
}

var scene: Scene;

Stage {
    title: "Application title"
    width: 600
    height: 600
    scene: scene = Scene {
        content: [
          Grid {
            rows: Row {
              cells: [
                ImageView {
                  image: Image { url: "{__DIR__}icons/lock.png" };
                  opacity: 0.2
                }
                Label {
                  graphic: ImageView {
                    image: Image { url: "{__DIR__}icons/image-x-generic.png" }
                  }
                  text: "en hel radda med text här"
                }
                ImageView {
                  image: Image { url: "{__DIR__}icons/preferences-system.png" };
                  //opacity: 0.2
                  onMouseClicked: function(e: MouseEvent) {
                    insert popupMenu into scene.content;
                    
                    var tx = e.sceneX - popupMenu.layoutBounds.width;
                    if(tx < 0 ) tx = 0;
                    popupMenu.translateX = tx;
                    var ty = e.sceneY; // - popupMenu.layoutBounds.height;
                    if(ty < 0 ) ty = 0;
                    popupMenu.translateY = ty;
                    popupMenu.visible = true;
                  }
                }
              ]
            }
          },
          
        ]
    }
}

//              onMouseClicked: function(e: MouseEvent) {
//                println("e: x={e.x}, y={e.y}");
//
//                //var b = iv.sceneToLocal(e.sceneX, e.sceneY);
//                var i1 = item.localToScene(0, 0);
//                println("i1: x={i1.x}, y={i1.y}");
//
//                var i2 = item.localToScene(e.sceneX, e.sceneY);
//                println("i2: x={i2.x}, y={i2.y}");
//
//                var iv1 = iv.localToScene(0, 0);
//                println("iv1: x={iv1.x}, y={iv1.y}");
//
//                var iv2 = iv.localToScene(e.sceneX, e.sceneY);
//                println("iv2: x={iv2.x}, y={iv2.y}");
//
//                println("");
//                // widgetOffsetY = b.height;
//                //showMenu(item, b.x, b.y);
//              }
