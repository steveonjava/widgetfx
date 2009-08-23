/*
 * ListItem.fx
 *
 * Created on 2009-jul-23, 22:45:42
 */
 
// <editor-fold defaultstate="collapsed" desc="imports...">

package se.pmdit.clipboardmanager.control;

import javafx.scene.Node;




import javafx.scene.control.Control;

// </editor-fold>

/**
 * @author pmd
 */

public class ListItem extends Control {

  var listItemSkin: AbstractListItemSkin = bind skin as AbstractListItemSkin;
  
  public var data: Object;
  public-read var hasData: Boolean = bind (data != null);

  /**
   * Defaults to 0 which means that the Skin controls the width
   */
  override public var width = 0;

  /**
   * Defaults to 0 which means that the Skin controls the height
   */
  override public var height = 0;
  
  public var selected: Boolean on replace {
      if(nodeIsListItemAware) {
          listItemAwareNode.onChangeSelected(selected);
      }
  };
  public var enabled: Boolean = true on replace {
      if(nodeIsListItemAware) {
          listItemAwareNode.onChangeEnabled(enabled);
      }
  };
  public-init var content: Object on replace {
      if(content instanceof ListItemListener) {
          nodeIsListItemAware = true;
          listItemAwareNode = content as ListItemListener;
      }
      else {  // For the future, if the node can be changed...
          nodeIsListItemAware = false;
          listItemAwareNode = null;
      }

      listItemSkin.onContentChanged(content);
  };

  var nodeIsListItemAware: Boolean;
  var listItemAwareNode: ListItemListener;

  public function moved(toPosition: Integer, fromPosition: Integer): Void {
      if(nodeIsListItemAware) {
          listItemAwareNode.onMove(toPosition, fromPosition);
      }
  }

  public function removed(): Void {
      if(nodeIsListItemAware) {
          listItemAwareNode.onRemoved();
      }
  }

  override public function create(): Node {
    return super.create();
  }

}
