/*
 * WidgetFX - JavaFX Desktop Widget Platform
 * Copyright (C) 2008  Stephen Chin
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.

 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.

 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
package org.widgetfx.widget;

import org.widgetfx.*;
import javafx.application.*;
import javafx.ext.swing.Canvas;
import javafx.scene.geometry.*;
import javafx.scene.paint.*;
import javafx.scene.image.*;
import javax.imageio.*;
import java.io.*;
import java.util.*;
import javafx.animation.*;

/**
 * @author Stephen Chin
 * @author Keith Combs
 */
Widget {
    name: "Slide Show";
    var fileImage : Image;
    stage: Stage {
        content: [
            Rectangle {width: 100, height: 100, fill: Color.BLUE},
            ImageView {
                image: bind fileImage
            }
        ]
    }
    onStart: function():Void {
        var directory = new File("C:\\Documents and Settings\\All Users\\Documents\\My Pictures\\anime\\wallpaper");
        var files = Arrays.asList(directory.listFiles());
        var counter = 0;
        var timeline = Timeline {
            repeatCount: Timeline.INDEFINITE;
            keyFrames: for (file in files) {
                KeyFrame {time: 5s * indexof file, action:function():Void {
                        fileImage = Image {url: file.toURL().toString(), size: 150};
                    }
                }

            }
        }
        timeline.start();
    }
}
