/*
 * ListItemMixin.fx
 *
 * Created on 2009-jul-23, 23:05:22
 */

package se.pmdit.screenshotfx.control;

import javafx.scene.Node;

/**
 * @author pmd
 */

public mixin class ListItemListener {

    public var thumbnail: Node;
    public var hasThumbnail: Boolean = false;
    
    public var onChangeSelected: function(:Boolean);
    public var onChangeEnabled: function(:Boolean);
    public var onMove: function(:Integer, :Integer);
    public var onAdded: function();

    /**
     * ListItem has been removed from NodeListView.
     * This is called after the next item in the NodeListView is selected.
     */
    public var onRemoved: function(node: Node);

}
