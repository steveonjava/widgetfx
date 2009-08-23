/*
 * ListItemBehavior.fx
 *
 * Created on 2009-aug-22, 01:34:02
 */

package se.pmdit.clipboardmanager.control;

import javafx.scene.control.Behavior;

import javafx.scene.input.MouseEvent;

/**
 * @author pmd
 */

public class ListItemBehavior extends Behavior {

  def listItemControl: ListItem = bind skin.control as ListItem;
  def listItemSkin: AbstractListItemSkin = bind skin as AbstractListItemSkin;

  public function onSelected(): Void {
    listItemControl.selected = true;
  }

  public function onToggleEnabled(): Void {
    listItemControl.enabled = not listItemControl.enabled;
  }

  public function onContentChanged(): Void {
  }

  public function onMouseEntered(e: MouseEvent): Void {
    listItemSkin.highlight(true);
  }

  public function onMouseExited(e: MouseEvent): Void {
    listItemSkin.highlight(false);
  }

}
