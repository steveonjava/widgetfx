/*
 * ListItemMixin.fx
 *
 * Created on 2009-jul-23, 23:05:22
 */

// <editor-fold defaultstate="collapsed" desc="imports...">
package se.pmdit.clipboardmanager.control;

import javafx.scene.Node;
// </editor-fold>

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
    public var onRemoved: function();

}
