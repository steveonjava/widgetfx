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
import se.pmdit.imageeditor.ImageEditor;

import java.awt.image.BufferedImage;

import org.jfxtras.scene.util.BoundsPainter;
import javafx.scene.control.Button;
import javafx.scene.effect.DropShadow;

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
              };
              addItem(ci);
            }
          }
        }
      }
    ]
  };

  var historySizeLimit = 10;
  var refreshRate: Duration = 2s;
  var history: ClipboardItem[] = [];
  var textHistory: String[];

  function addItem(ci: ClipboardItem): Void {
    var btn: Button;
    var item: ListItem = ListItem {
      //width: bind itemListView.visibleWidth
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
                var itemLocalToParent = item.localToParent(0, 0);
                showMenu(item, e.sceneX, itemLocalToParent.y);
              }
            }
//            btn = Button {
//              //graphic:
//              text: "aa"
//              //onMouseClicked:
//              onMouseClicked: function(e: MouseEvent) {
//                showMenu(item, e.sceneX, e.sceneY);
//              }
//            }
            
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

  public function removeItem(clipboardItem: ClipboardItem, force: Boolean): Void {
    var index = -1;
    for(ci in history where ci.equals(clipboardItem)) {
      index = indexof ci;
    }

    if(index >= 0) {
      removeItem(index, force);
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

  var popupMenuItem: ListItem;
  var popupMenu: Group = Group {
    var vbox: VBox;
    content: Group {
      opacity: 0.9
      blocksMouse: true
      //visible: false
      content: [
        Rectangle {
          arcHeight: 15
          arcWidth: 15
          width: 100 //bind vbox.layoutBounds.width + 10
          height: 100 //bind vbox.layoutBounds.height + 10
          fill: Color.WHITE
          effect: DropShadow {
            offsetX: 3
            offsetY: 3
            color: Color.BLACK
            radius: 3
          }
        }
        vbox = VBox {
          layoutX: 5
          layoutY: 5
          spacing: 5
          content: [
            Hyperlink {
              text: "close menu"
              action: function() {
                popupMenu.visible = false;
              }
            }
            Hyperlink {
              text: "set in clipboard"
              action: function() {
                popupMenu.visible = false;
                var ci = popupMenuItem.data as ClipboardItem;
                removeItem(ci, true);
                clipboard.setContent(ci.data);
              }
            }
            Hyperlink {
              //opacity: bind if((popupMenuItem.data as ClipboardItem).type == ClipboardItem.IMAGE) 0.5 else 1
              disable: bind ((popupMenuItem.data as ClipboardItem).type != ClipboardItem.IMAGE)
              text: "edit"
              action: function() {
                popupMenu.visible = false;
                editItem(popupMenuItem);
              }
            }
            Hyperlink {
              text: "delete"
              action: function() {
                popupMenu.visible = false;
                removeItem(popupMenuItem.data as ClipboardItem, true);
              }
            }
          ]
        }
      ]
    }
  }

  function showMenu(item: ListItem, x: Number, y: Number) {
    popupMenuItem = item;
    
    var tx = x - popupMenu.layoutBounds.width; //popupMenu.layoutBounds.width;
    if(tx < 0 ) tx = 0;
    popupMenu.translateX = tx;
    var ty = y - (popupMenu.layoutBounds.height / 5); // - popupMenu.layoutBounds.height;
    if(ty < 0 ) ty = 0;
    popupMenu.translateY = ty;

    popupMenu.visible = true;
  }

  function editItem(item: ListItem): Void {
    var ci: ClipboardItem = item.data as ClipboardItem;

    if(ci.type == ClipboardItem.TEXT) {
      var editor = TextEditor {}
      editor.setText(ci.text);
      editor.show();
    }
    else if(ci.type == ClipboardItem.IMAGE) {
      ImageEditor {
        bf: (ci.value as BufferedImage)
      }
    }
  }

  var itemListView: NodeListView = NodeListView {
    //layoutY: 20
    width: bind widgetWidth - 10
    height: bind widgetHeight - 20
  };

  public var mainContent: Node[] = bind [
    Group {
      content: [
        itemListView,
        popupMenu
      ]
    }
  ];

  postinit {
    timer.play();
    popupMenu.visible = false;
  }

}