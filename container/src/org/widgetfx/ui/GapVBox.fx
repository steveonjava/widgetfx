/*
 * GapVBox.fx
 *
 * Created on Aug 22, 2008, 6:46:44 PM
 */

package org.widgetfx.ui;

import com.sun.scenario.scenegraph.SGNode;
import com.sun.scenario.scenegraph.SGGroup;
import javafx.scene.Group;

/**
 * @author Stephen Chin
 * @author Keith Combs
 */
public class GapVBox extends Group {

    public attribute spacing:Number on replace {
        impl_requestLayout();
    }
    
    /**
     * Index of the gap.  The gap will get inserted before the component at this index.
     */
    public attribute gapIndex:Integer on replace {
        impl_requestLayout();
    }
    
    public attribute gapSize:Integer on replace {
        impl_requestLayout();
    }

    init {
        impl_layout = doGapVBoxLayout;
    }

    private function doGapVBoxLayout(g:Group):Void {
        var x:Number = 0;
        var y:Number = 0;
        for (node in content) {
            if (gapSize > 0 and indexof node == gapIndex) {
                y += gapSize + spacing;
            }
            if (node.visible) {
                node.impl_layoutX = x;
                node.impl_layoutY = y;
                y += node.getBoundsHeight() + spacing;
            }
        }
    }
}
