/*
 * ListItemSkin.fx
 *
 * Created on 2009-aug-22, 01:26:58
 */

package se.pmdit.clipboardmanager.control;

import javafx.scene.control.Skin;

import javafx.scene.Group;
import javafx.scene.image.Image;
import javafx.scene.image.ImageView;
import javafx.scene.input.MouseEvent;
import javafx.scene.layout.VBox;
import javafx.scene.shape.Rectangle;
import org.jfxtras.scene.border.SoftBevelBorder;

import javafx.scene.Node;

import javafx.scene.paint.Color;

/**
 * @author pmd
 */

public class ListItemThumbnailSkin extends AbstractListItemSkin {

  var thumbnail: Node;
  // TODO: Should of course be skinned...
  var baseColorLight2 = Color.web("#6a615c");
  var baseColorLight = Color.web("#4a413c");
  var baseColorDark = Color.web("#2a211c");
  var baseColor = Color.web("#3a312c");

  init {
    node = SoftBevelBorder {
          borderWidth: 1
          borderColor: baseColorLight
          raised: bind not listItemControl.selected
          node: Group {
              content: [
                  Rectangle {
                      x: bind thumbnail.layoutBounds.minX - 33     // TODO: fix hardcoded...
                      y: bind thumbnail.layoutBounds.minY - 3
                      width: bind thumbnail.layoutBounds.width + 36
                      height: bind thumbnail.layoutBounds.height + 6
                      fill: baseColor
                      onMouseClicked: function(e: MouseEvent) {
                          listItemBehavior.onSelected();
                      }
                  },
                  VBox {
                      translateX: -27 // TODO: fix hardcoded...
                      translateY: 3
                      content: [
                          ImageView {
                              opacity: bind if(listItemControl.selected) 1 else 0.3
                              image: bind if(listItemControl.selected) Image { url: "{__DIR__}lightbulb.png" }
                                      else Image { url: "{__DIR__}lightbulb_off.png" }
                          }
                          ImageView {
                              opacity: bind if(listItemControl.enabled) 1 else 0.3
                              image: Image { url: "{__DIR__}eye.png" }
                              onMouseClicked: function(e: MouseEvent) {
                                  listItemBehavior.onToggleEnabled();
                              }
                          }
                      ]
                  },
                  thumbnail
              ]
          }
      }
  }

  override public function onContentChanged(node: Object): Void {
    var listener: ListItemListener = null;
    if(node instanceof ListItemListener) {
      listener = (node as ListItemListener);
    }

    thumbnail = if(listener != null and listener.hasThumbnail) listener.thumbnail else node as Node;

    super.onContentChanged(node);
  }
  
}
