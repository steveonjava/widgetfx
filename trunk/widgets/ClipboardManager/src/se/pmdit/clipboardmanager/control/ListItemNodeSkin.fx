/*
 * ListItemSkin.fx
 *
 * Created on 2009-aug-22, 01:26:58
 */

package se.pmdit.clipboardmanager.control;







import javafx.scene.Node;




/**
 * @author pmd
 */

public class ListItemNodeSkin extends AbstractListItemSkin {

  override var width = bind listItemControl.width;
  override var height = bind listItemControl.height;

  init {
  }

  override public function onContentChanged(content: Object): Void {
    this.content = content as Node;

    super.onContentChanged(content);
  }

}
