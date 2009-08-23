/*
 * ListItemSkin.fx
 *
 * Created on 2009-aug-22, 01:26:58
 */

package se.pmdit.clipboardmanager.control;




import javafx.scene.control.Label;

import javafx.scene.image.Image;

import javafx.scene.image.ImageView;




/**
 * @author pmd
 */

public class ListItemLabelSkin extends AbstractListItemSkin {

  override var width = bind listItemControl.width;
  override var height = bind listItemControl.height;
  var text: String = "";
  public var icon: Image;

  init {
    content = Label {
      width: bind width
      text: bind text
      graphic: ImageView {
        image: icon
      }
    }
  }

  override public function onContentChanged(content: Object): Void {
    this.text = content as String;

    super.onContentChanged(content);
  }

}
