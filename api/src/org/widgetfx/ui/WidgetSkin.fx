/*
 * WidgetSkin.fx
 *
 * Created on May 26, 2009, 6:46:43 PM
 */

package org.widgetfx.ui;

import org.jfxtras.scene.control.AbstractSkin;

import javafx.scene.Node;

/**
 * @author kcombs
 */

public class WidgetSkin extends AbstractSkin {
    public var scene:Node on replace {
        node = scene;
    }
}
