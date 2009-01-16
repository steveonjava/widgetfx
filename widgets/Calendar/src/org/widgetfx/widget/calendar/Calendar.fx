/*
 * CalendarWidget.fx
 *
 * Created on Jan 15, 2009, 7:31:40 PM
 */

package org.widgetfx.widget.calendar;

/**
 * @author kcombs
 */
import org.widgetfx.*;
import javafx.scene.control.*;
import javafx.scene.shape.*;

def calendar:Widget = Widget {
    width: 300
    height: 220
    aspectRatio: 4.0/3.0
    skin: Skin {
        scene: Rectangle{width: 200, height: 200}
    }

}
return calendar;
