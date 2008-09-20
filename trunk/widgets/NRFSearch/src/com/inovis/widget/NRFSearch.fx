/*
 * NRFSearch.fx
 *
 * Created on Sep 19, 2008, 6:00:26 PM
 */

package com.inovis.widget;

import org.widgetfx.*;
import javafx.application.*;
import javafx.scene.geometry.*;
import javafx.scene.paint.*;

/**
 * @author Stephen Chin
 * @author Keith Comb
 */
Widget {
    resizable: true
    stage: Stage {
        width: 300
        height: 300
        content: [
            Rectangle {
                width: 300
                height: 300
                fill: Color.BLUE
            }
        ]
    }
}