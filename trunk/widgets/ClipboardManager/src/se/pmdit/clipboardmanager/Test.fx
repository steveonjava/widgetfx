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