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
var directoryName = (new File(home, "My Documents\\My Pictures")).getAbsolutePath();
var directory:File = bind loadDirectory(directoryName);

function loadDirectory(directoryName:String):File {
    System.out.println("load directory called: {directoryName}");
    var directory = new File(directoryName);
    if (directory.exists()) {
        var worker:JavaFXWorker = JavaFXWorker {
            inBackground: function() {
                return 
                getKeyFrames(directory) as Object;
            }
            onDone: function(result) {
                var timeline = Timeline {
                    repeatCount: Timeline.INDEFINITE;
                    keyFrames: worker.result as KeyFrame[];
                }
                timeline.start();
            }
        }
    }
    return directory;
}

var fileImage : Image;
var start = 0s;
var width = 150;
var height = 112;

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
                    var size = java.lang.Math.max(height, width);
                    var worker:JavaFXWorker = JavaFXWorker {
                        inBackground: function() {
                            return Image {url: file.toURL().toString(), size: size};
                        }
                        
                        onDone: function(result) {
                            fileImage = worker.result as Image;
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
            TextField {text: bind directoryName with inverse}
        ]
    }
    stage: Stage {
        width: bind width with inverse
        height: bind height with inverse
        content: [
            ImageView {
                image: bind fileImage
            }
        ]
    }
}
