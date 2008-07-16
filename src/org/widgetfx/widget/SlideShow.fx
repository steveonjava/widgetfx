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
import javafx.ext.swing.*;
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
var home = System.getProperty("user.home");
var directory = new File(home, "My Documents\\My Pictures");
var fileImage : Image;
var start = 0s;
var width = 150;
var height = bind width * 3 / 4;

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
                    JavaFXWorker {
                        background: function() {
                            return Image {url: file.toURL().toString(), size: bind java.lang.Math.max(height, width)};
                        }
                        
                        action: function(result) {
                            fileImage = result as Image;
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
    name: "Slide Show"
    resizable: true
    config: FlowPanel {
        content: [
            Label {text: "Directory:"},
            TextField {text: directory.toString()}
        ]
    }
    stage: Stage {
        width: bind width with inverse
        height: bind height
        content: [
            ImageView {
                image: bind fileImage
            }
        ]
    }
    onStart: function():Void {
        if (directory.exists()) {
            JavaFXWorker {
                background: function() {
                    return getKeyFrames(directory) as Object;
                }
                action: function(result) {
                    var timeline = Timeline {
                        repeatCount: Timeline.INDEFINITE;
                        keyFrames: result as KeyFrame[];
                    }
                    timeline.start();
                }
            }
        }
    }
}
