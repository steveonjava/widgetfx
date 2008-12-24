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

 * This particular file is subject to the "Classpath" exception as provided
 * in the LICENSE file that accompanied this code.

 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
package org.widgetfx.widget.slideshow;

import org.widgetfx.*;
import org.widgetfx.config.*;
import org.jfxtras.layout.*;
import org.jfxtras.async.*;
import javafx.ext.swing.*;
import javafx.scene.*;
import javafx.scene.control.*;
import javafx.scene.shape.*;
import javafx.scene.paint.*;
import javafx.scene.image.*;
import javafx.scene.text.*;
import javafx.util.*;
import javafx.animation.*;
import javafx.lang.*;
import javax.imageio.*;
import java.io.*;
import java.util.*;
import java.lang.*;
import javax.swing.*;
import javax.swing.event.ChangeListener;

/**
 * @author Stephen Chin
 * @author Keith Combs
 */
var home = System.getProperty("user.home");
var defaultDirectories:File[] = [
    new File(home, "Pictures"),
    new File(home, "My Documents\\My Pictures"),
    new File(home)
][d|d.exists()];
var directoryName:String;
var directory:File;
var status = "Loading Images...";
var imageFiles:String[];
var shuffle = true;
var duration:Integer = 10;
var keywords : String;
var imageIndex:Integer;
var imageWidth:Number;
var imageHeight:Number;
var currentFile:String;
var currentImage:Image;
var nextImage:Image;
var worker:JavaFXWorker;
var timeline:Timeline;
var tabbedPane:JTabbedPane;
var maxFiles = 10000;
var maxFolders = 1000;
var folderCount = 0;
var fileCount = 0;

function initTimeline() {
    imageIndex = 0;
    timeline = Timeline {
        repeatCount: Timeline.INDEFINITE
        keyFrames: [
            KeyFrame {time: 0s,
                action: function() {
                    currentFile = imageFiles[imageIndex++ mod imageFiles.size()];
                    updateImage();
                }
            },
            KeyFrame {time: 1s * duration}
        ]
    }
}

function updateImage():Void {
//    if (not (new File(currentFile)).exists()) {
//        currentImage = null;
//        status = "Missing File: {currentFile}";
//        return;
//    }
    if (worker != null) {
        worker.cancel();
    }
    worker = JavaFXWorker {
        inBackground: function() {
            
            var image = Image {url: currentFile, width: imageWidth, height: imageHeight, preserveRatio: true};
            if (image.error) {
                throw new RuntimeException("Error loading image: {currentFile}");
            }
            return image;
        }
        onDone: function(result) {
            currentImage = result as Image;
            status = "";
            System.runFinalization();
            System.gc();
        }
        onFailure: function(e) {
            currentImage = null;
            status = "Error Loading Image: {currentFile}";
        }
    }
}

function loadDirectory() {
    var directory = new File(directoryName);
    currentImage = null;
    timeline.stop();
    if (worker != null) {
        worker.cancel();
    }
    if (not directory.exists()) {
        status = "Directory Doesn't Exist";
    } else if (not directory.isDirectory()) {
        status = "Selected File is Not a Directory";
    } else {
        status = "Loading Images...";
        folderCount = 0;
        fileCount = 0;
        imageFiles = getImageFiles(directory);
        if (fileCount > maxFiles) {
            println("Slide Show exceeded limit of {maxFiles} image files.");
        }
        if (folderCount > maxFolders) {
            println("Slide Show exceeded limit of {maxFolders} folders to scan.");
        }
        if (imageFiles.size() > 0) {
            if (shuffle) {
                imageFiles = Sequences.shuffle(imageFiles) as String[];
            }
            initTimeline();
            timeline.play();
        } else {
            status = "No Images Found"
        }
    }
}

function excludesFile(name:String):Boolean {
    if (keywords != null and keywords.length() > 0) {
        if (name.toLowerCase().contains(keywords.toLowerCase())) {
            return true;
        }
    }
    return false;
}

function getImageFiles(directory:File):String[] {
    var emptyFile:String[] = [];
    if (folderCount++ >= maxFolders or fileCount >= maxFiles) {
        return emptyFile;
    }
    var fileArray = directory.listFiles();
    if (fileArray == null) {
        return emptyFile;
    }
    var files = Arrays.asList(fileArray);
    return for (file in files) {
        var name = file.getName();
        if (excludesFile(name)) {
            emptyFile;
        } else {
            var index = name.lastIndexOf('.');
            var extension = if (index == -1) null else name.substring(index + 1);
            if (file.isDirectory()) {
                getImageFiles(file);
            } else if (extension != null and ImageIO.getImageReadersBySuffix(extension).hasNext()) {
                fileCount++;
                var url = file.toURL();
                var uri = new java.net.URI(url.getProtocol(), url.getUserInfo(), 
                    url.getHost(), url.getPort(), url.getPath(), url.getQuery(), url.getRef());
                uri.toString().replaceAll("#", "%23");
            } else {
                emptyFile;
            }
        }
    }
}

var browseButton:SwingButton = SwingButton {
    text: "Browse...";
    action: function() {
        var chooser:JFileChooser = new JFileChooser(directoryName);
        chooser.setFileSelectionMode(JFileChooser.DIRECTORIES_ONLY);
        var returnVal = chooser.showOpenDialog(browseButton.getJButton());
        if (returnVal == JFileChooser.APPROVE_OPTION) {
            directoryName = chooser.getSelectedFile().getAbsolutePath();
        }
    }
}

function setDefaultDirectory() {
    directoryName = (defaultDirectories[0]).getAbsolutePath();
}

function getConfigUI():Grid {
    var directoryLabel = Text {content: "Directory:"};
    var directoryEdit = TextBox {text: bind directoryName with inverse, columns: 40};
    var keywordLabel = Text {content: "Filter:"};
    var keywordEdit = TextBox {text: bind keywords with inverse, columns: 40};
    var durationLabel = Text {content: "Duration"};
    var shuffleCheckBox = SwingCheckBox {text: "Shuffle", selected: bind shuffle with inverse};

    // do this after TextBox is created to work around a JavaFX initialization bug
    setDefaultDirectory();

    // todo - replace with javafx spinner when one exists
    var durationSpinner = new JSpinner(new SpinnerNumberModel(duration, 2, 60, 1));
    durationSpinner.addChangeListener(ChangeListener {
        override function stateChanged(e):Void {
            duration = durationSpinner.getValue() as Integer;
        }
    });
    var durationSpinnerComponent = SwingComponent.wrap(durationSpinner);

    return Grid {
        rows: [
            Row {
                cells: [directoryLabel, directoryEdit, browseButton]
            },
            Row {
                cells: [keywordLabel, Cell {content: keywordEdit, columnSpan: 2}]
            },
            Row {
                cells: [durationLabel, Cell {content: durationSpinnerComponent, preferredWidth: 52}]
            }
            Row {
                cells: shuffleCheckBox
            }
        ]
    }
}

var slideShow:Widget = Widget {
    launchHref: "SlideShow.jnlp";
    width: 300
    height: 200
    aspectRatio: 4.0/3.0
    configuration: Configuration {
        properties: [
            StringProperty {
                name: "directoryName"
                value: bind directoryName with inverse
            },
            BooleanProperty {
                name: "shuffle"
                value: bind shuffle with inverse
            },
            IntegerProperty {
                name: "duration"
                value: bind duration with inverse
            },
            StringProperty {
                name : "keywords"
                value : bind keywords with inverse
            },
            IntegerProperty {
                name: "maxFiles"
                value: bind maxFiles with inverse
            },
            IntegerProperty {
                name: "maxFolders"
                value: bind maxFolders with inverse
            }
        ]
        scene: Scene {
            content: getConfigUI()
        }

        onLoad: function() {
            imageWidth = slideShow.width;
            imageHeight = slideShow.height;
            loadDirectory();
        }
        onSave: loadDirectory;
    }
    var view:ImageView;
    content: [
        view = ImageView {
            x: bind (slideShow.width - view.boundsInLocal.width) / 2
            y: bind (slideShow.height - view.boundsInLocal.height) / 2
            fitWidth: bind slideShow.width
            fitHeight: bind slideShow.height
            preserveRatio: true
            smooth: true
            image: bind currentImage
        },
        Group {
            var text:Text;
            content: [
                Rectangle {
                    width: bind slideShow.width
                    height: bind slideShow.height
                    fill: Color.BLACK
                    arcWidth: 8, arcHeight: 8
                },
                text = Text {
                    translateY: bind slideShow.height / 2
                    translateX: bind (slideShow.width - text.boundsInLocal.width) / 2
                    content: bind status
                    fill: Color.WHITE
                }
            ]
            opacity: bind if (status.isEmpty()) 0 else 1;
        }
    ]
    onResize: function(width:Number, height:Number) {
        if (imageWidth != width or imageHeight != height) {
            imageWidth = width;
            imageHeight = height;
            if (status.isEmpty()) {
                updateImage();
            }
        }
    }
}
return slideShow;
