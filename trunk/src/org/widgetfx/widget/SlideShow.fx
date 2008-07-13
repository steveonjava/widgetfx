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
import org.widgetfx.util.*;
import javafx.application.*;
import javafx.ext.swing.Canvas;
import javafx.scene.geometry.*;
import javafx.scene.paint.*;
import javafx.scene.image.*;
import javax.imageio.*;
import java.io.*;
import java.util.*;
import javafx.animation.*;
import javafx.lang.*;
import java.lang.*;

/**
 * @author Stephen Chin
 * @author Keith Combs
 */
var fileImage : Image;
var start = 0s;

private function getKeyFrames(directory:File):KeyFrame[] {
    var files = Arrays.asList(directory.listFiles());
    return for (file in files) {
        var name = file.getName();
        var index = name.lastIndexOf('.');
        var extension = if (index == -1) then null else name.substring(index + 1);
        if (file.isDirectory()) {
            getKeyFrames(file);
        } else if (ImageIO.getImageReadersBySuffix(extension).hasNext()) {
            var keyFrame = KeyFrame {time: start, action:function():Void {
                    BackgroundTask {
                        action: function():Void {
                            fileImage = Image {url: file.toURL().toString(), size: 150};
                        }
                    }
                }
            }
            start = start + 10s;
            keyFrame;
        } else {
            []
        }
    }
}

Widget {
    name: "Slide Show";
    stage: Stage {
        content: [
            Rectangle {width: 100, height: 100, fill: Color.BLUE},
            ImageView {
                image: bind fileImage
            }
        ]
    }
    onStart: function():Void {
        var home = System.getProperty("user.home");
        var directory = new File(home, "My Documents\\My Pictures");
        if (directory.exists()) {
            var counter = 0;
            var timeline = Timeline {
                repeatCount: Timeline.INDEFINITE;
                keyFrames: getKeyFrames(directory);
            }
            timeline.start();
        }
    }
}
