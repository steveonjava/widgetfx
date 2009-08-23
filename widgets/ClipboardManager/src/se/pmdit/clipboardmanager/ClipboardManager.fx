/*
* Main.fx
 *
 * Created on 2009-feb-27, 18:58:22
 */

package se.pmdit.clipboardmanager;

import javafx.animation.KeyFrame;
import javafx.animation.Timeline;
import javafx.lang.Duration;
import javafx.scene.image.Image;
import javafx.scene.layout.HBox;

import javafx.scene.Node;
import se.pmdit.clipboardmanager.control.*;



import javafx.scene.layout.LayoutInfo;

import javafx.scene.control.Label;
import javafx.scene.image.ImageView;
import org.jfxtras.scene.layout.Grid;
import org.jfxtras.scene.layout.Row;



import javafx.scene.input.MouseEvent;

import javafx.scene.Group;
import javafx.scene.control.Hyperlink;
import javafx.scene.layout.VBox;
import javafx.scene.paint.Color;
import javafx.scene.shape.Rectangle;
import org.jfxtras.scene.border.LineBorder;


import javafx.scene.control.OverrunStyle;

/**
 * @author pmd
 */

public mixin class ClipboardManager {
  public var widgetWidth: Number;
  public var widgetHeight: Number;

  def clipboard: ClipboardHandler = ClipboardHandler.getInstance();
  def timer: Timeline = Timeline {
    repeatCount: Timeline.INDEFINITE
    keyFrames: [
      KeyFrame {
        time: bind refreshRate
        action: function(): Void {
          if(clipboard.isRetryLater()) {
            //image = images[REFRESH];
          }
          else {
            if(clipboard.isUpdated()) {
              var ci = ClipboardItem {
                data: clipboard.getData()
                //value: clipboard.getCurrentValue()
                //mimeType: clipboard.getCurrentMimeType()
              };
              addItem(ci);
//                          clipboardMimeType = clipboard.getCurrentMimeType();
//                          clipboardContent = clipboard.getCurrentValue();
            }
            else if(clipboard.isMimeTypeUpdated()) {
              //clipboardMimeType = clipboard.getCurrentMimeType();
            }
          }
        }
      }
    ]
  };

var historySizeLimit = 3;
var refreshRate: Duration = 750ms;
//var clipboardContent: String on replace {
//    insert clipboardContent before textHistory[0];
//    addItem(clipboardContent);
//    if(sizeof textHistory > historySizeLimit) {
//      delete textHistory[historySizeLimit];
//
//    }
//    for(str in textHistory) {
//        java.lang.System.out.println("{str}");
//    }
//    java.lang.System.out.println("");
//};

  var history: ClipboardItem[] = [];
  var textHistory: String[];
//var items: ClipboardItem[] = [
//    ClipboardItem {
//        text: "test";
//        image: images[REFRESH];
//    }
//];

  function addItem(ci: ClipboardItem): Void {
    var item: ListItem = ListItem {
      data: ci
      content: Grid {
        rows: Row {
          cells: [
            ImageView {
              image: Image { url: "{__DIR__}icons/lock.png" };
              opacity: bind if(ci.stored) 1 else 0.2
              onMouseClicked: function(e: MouseEvent) {
                ci.stored = not ci.stored;
              }
            },
            Label {
              textOverrun: OverrunStyle.ELLIPSES
              textWrap: false
              graphic: ImageView {
                image: ci.image
              }
              text: ci.text.replaceAll("\n", " | ")
              layoutInfo: LayoutInfo {
                width: bind itemListView.width - 50
              }
            },
            ImageView {  // TODO: add background to make "real" button = whole button area
              image: Image { url: "{__DIR__}icons/preferences-system.png" };
              onMouseClicked: function(e: MouseEvent) {
                showMenu(item, e.sceneX, e.sceneY);
              }
            }
          ]
        }
      }
      skin: ListItemNodeSkin {};
      layoutInfo: LayoutInfo { width: bind item.width, height: 24 }
    }

    insert ci before history[0];
    itemListView.add(item);

    if(sizeof history > historySizeLimit) {
      removeItem(historySizeLimit, false);
    }
  }

  // TODO: not able to keep all or delete all > historyMax if it can?
  public function removeItem(index: Integer, force: Boolean): Void {
    var ci = history[index];
    if(ci.stored and not force) {
      if(index > 1) {
        if(history[index - 1] != null) {
          removeItem(index - 1, force);
        }
      }
    }
    else {
      delete history[index];
      itemListView.remove(index);
    }
  }

  var popupMenu: Group = Group {};
  function showMenu(item: ListItem, x: Number, y: Number) {
    var vbox: VBox;
    popupMenu.content = Group {
      opacity: 0.9
      content: [
        LineBorder {
          thickness: 1
          lineColor: Color.LIGHTGRAY
          node: Group {
            content: [
              Rectangle {
                width: 140
                height: bind vbox.layoutBounds.height + 10
                fill: Color.WHITE
              }
              vbox = VBox {
                layoutX: 5
                layoutY: 5
                spacing: 5
                content: [
                  Hyperlink {
                    text: "set in clipboard"
                    action: function() {
                      popupMenu.visible = false;
                      clipboard.setContent((item.data as ClipboardItem).text);
                      //delete popupMenu from mainContent;
                    }
                  }
                  Hyperlink {
                    text: "edit"
                    action: function() {
                      popupMenu.visible = false;
                      //delete popupMenu from mainContent;
                      editItem(item);
                    }
                  }
                  Hyperlink {
                    text: "close menu"
                    action: function() {
                      popupMenu.visible = false;
                      //delete popupMenu from mainContent;
                    }
                  }
                ]
              }
            ]
          }
        }
      ]
    };
  
    //insert popupMenu into mainContent;
    
    var tx = x - 140; //popupMenu.layoutBounds.width;
    if(tx < 0 ) tx = 0;
    popupMenu.translateX = tx;
    var ty = y; // - popupMenu.layoutBounds.height;
    if(ty < 0 ) ty = 0;
    popupMenu.translateY = ty;
    popupMenu.visible = true;

    println("pop: {popupMenu.boundsInParent.minX}, {popupMenu.boundsInParent.minY}");
    popupMenu.toFront();
  }

  function editItem(item: ListItem): Void {
    var ci: ClipboardItem = item.data as ClipboardItem;
    if(ci.type == ClipboardItem.TEXT) {
      var editor = TextEditor {}
      editor.setText(ci.text);
      editor.show();
    }
  }

  var itemListView: NodeListView = NodeListView {
    width: bind widgetWidth - 10
    height: bind widgetHeight
  };

  public var mainContent: Node[] = bind [
      HBox {
        content: [
          itemListView,
        ]
      }
      popupMenu
  ];

  postinit {
    timer.play();
  }

}