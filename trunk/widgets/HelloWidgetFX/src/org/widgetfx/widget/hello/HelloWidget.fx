/*
 * HelloWidget.fx
 *
 * Created on Jan 6, 2009, 5:37:59 PM
 */
package org.widgetfx.widget.hello;

import org.widgetfx.*;
import javafx.scene.control.*;
import javafx.scene.image.*;

/**
 * @author Stephen Chin
 * @author Keith Combs
 */
var monitorImage = Image {
    url: "{__DIR__}WidgetFXMonitor.png"
}

Widget {
    launchHref: "HelloWidgetFX"
    resizable: false
    width: monitorImage.width
    height: monitorImage.height
    skin: Skin {
        scene: ImageView {
            image: monitorImage
        }
    }
}
