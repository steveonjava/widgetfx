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
import javafx.util.*;
import javafx.animation.*;
import javafx.lang.*;
import javax.imageio.*;
import java.io.*;
import java.util.*;
import java.lang.*;
import javax.swing.JFileChooser;

/**
 * @author Stephen Chin
 * @author Keith Combs
 */
var home = System.getProperty("user.home");
var directoryName = (new File(home, "My Documents\\My Pictures")).getAbsolutePath();
var directory:File = bind loadDirectory(directoryName);
var imageFiles:File[];
var random = true;
var width = 150;
var height = 100;
var imageIndex = 0;
var imageHeight = height;
var currentFile:File;
var currentImage:Image;
var worker:JavaFXWorker;
var timeline = Timeline {
    repeatCount: Timeline.INDEFINITE
    keyFrames: [
        KeyFrame {time: 0s,
            action: function() {
                currentFile = imageFiles[imageIndex++ mod imageFiles.size()];
                updateImage();
            }
        },
        KeyFrame {time: 15s}
    ]
}

private function updateImage():Void {
    if (currentFile == null or not currentFile.exists()) {
        return;
    }
    if (worker <> null) {
        worker.cancel();
    }
    worker = JavaFXWorker {
        inBackground: function() {
            var image = Image {url: currentFile.toURL().toString(), height: imageHeight};
            return image;
        }
        onDone: function(result) {
            if (worker.result <> null) {
                currentImage = worker.result as Image;
            }
        }
    }
}

private function loadDirectory(directoryName:String):File {
    var directory = new File(directoryName);
    if (directory.exists()) {
        timeline.stop();
        var worker:JavaFXWorker = JavaFXWorker {
            inBackground: function() {
                var imageFiles = getImageFiles(directory);
                if (random) {
                    imageFiles = Sequences.shuffle(imageFiles) as File[];
                }
                return imageFiles as Object;
            }
            onDone: function(result) {
                imageFiles = worker.result as File[];
                timeline.start();
            }
        }
    }
    return directory;
}

private function getImageFiles(directory:File):File[] {
    var files = Arrays.asList(directory.listFiles());
    return for (file in files) {
        var name = file.getName();
        var index = name.lastIndexOf('.');
        var extension = if (index == -1) then null else name.substring(index + 1);
        if (file.isDirectory()) {
            getImageFiles(file);
        } else if (ImageIO.getImageReadersBySuffix(extension).hasNext()) {
            file
        } else {
            []
        }
    }
}

Widget {
    name: "Slide Show"
    resizable: true
    aspectRatio: 4.0/3.0
    configuration: Configuration {
        component: FlowPanel {
            var browsebutton:Button = Button {
                    text: "Browse...";
                    action: function() {
                        var chooser:JFileChooser = new JFileChooser(directoryName);
                        chooser.setFileSelectionMode(JFileChooser.DIRECTORIES_ONLY);
                        var returnVal = chooser.showOpenDialog(browsebutton.getJButton());
                        if (returnVal == JFileChooser.APPROVE_OPTION) {
                            directoryName = chooser.getSelectedFile().getAbsolutePath();
                        }
                    }
                }
            content: [
                Label {text: "Directory:"},
                TextField {text: bind directoryName with inverse},
                browsebutton
            ]
        }
        onSave: function() {
            loadDirectory(directoryName);
        }
    }
    stage: Stage {
        width: bind width with inverse
        height: bind height with inverse
        content: [
            ImageView {
                image: bind currentImage
            }
        ]
    }
    onResize: function(width:Integer, height:Integer) {
        if (imageHeight <> height) {
            imageHeight = height;
            updateImage();
        }
    }
}
