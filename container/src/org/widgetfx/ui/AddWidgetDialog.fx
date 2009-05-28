/*
 * WidgetFX - JavaFX Desktop Widget Platform
 * Copyright (c) 2008-2009, WidgetFX Group
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 1. Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 * 3. Neither the name of WidgetFX nor the names of its contributors may be used
 *    to endorse or promote products derived from this software without
 *    specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */
package org.widgetfx.ui;

import java.io.File;
import javafx.ext.swing.*;
import javafx.scene.*;
import javafx.scene.image.*;
import javafx.scene.layout.*;
import javafx.scene.paint.*;
import javafx.scene.shape.*;
import javafx.stage.*;
import javax.swing.JFileChooser;
import javax.swing.filechooser.FileFilter;
import org.jfxtras.stage.*;
import org.jfxtras.scene.layout.*;
import org.jfxtras.scene.layout.LayoutConstants.*;
import org.widgetfx.*;
import org.widgetfx.config.*;

/**
 * @author Stephen Chin
 */
public class AddWidgetDialog {
    
    public-init var addHandler:function(jnlpUrl:String):Void;
    
    public-init var cancelHandler:function():Void;
    
    public-init var owner:Stage;
    
    var jnlpUrl:String;
    
    var dialog:JFXDialog;
    
    postinit {
        showDialog();
    }
    
    var selected:SwingListItem on replace {
        jnlpUrl = selected.text;
    }
    
    function add() {
        if (addHandler != null) {
            addHandler(jnlpUrl);
        }
        dialog.close();
    }
    
    function cancel() {
        if (cancelHandler != null) {
            cancelHandler();
        }
        dialog.close();
    }
    
    function showDialog() {
        var widgetList = SwingList {
            selectedItem: bind selected with inverse
            items: for (url in WidgetManager.getInstance().recentWidgets) SwingListItem {
                text: url
            }
        }
        var listLabel = SwingLabel {text: "Recent Widgets:", labelFor: widgetList}
        var jarField = SwingTextField {text: bind jnlpUrl with inverse, columns: 30, action: add};
        var jarLabel = SwingLabel {text: "Widget URL:", labelFor: jarField};
        var browseButton:SwingButton = SwingButton {
            text: "Browse...";
            action: function() {
                var chooser = new JFileChooser(jnlpUrl);
                chooser.setFileFilter(FileFilter {
                    override function accept(f:File):Boolean {
                        return f.isDirectory() or f.getName().toLowerCase().endsWith(".jnlp") or f.getName().toLowerCase().endsWith(".swf") or f.getName().toLowerCase().endsWith(".swfi");
                    }
                    override function getDescription():String {
                        return "WidgetFX Widget (JNLP or SWF)"
                    }
                });
                var returnVal = chooser.showOpenDialog(browseButton.getJButton());
                if (returnVal == JFileChooser.APPROVE_OPTION) {
                    jnlpUrl = chooser.getSelectedFile().toURL().toString();
                }
            }
        }
        
        dialog = JFXDialog {
            title: "Add Widget"
            resizable: false
            icons: Image {
                url: "{__DIR__}images/WidgetFXIcon16.png"
            }
            owner: owner
            scene: Scene {
                var grid:Grid;
                content: grid = Grid {
                    growRows: [1]
                    var box:HBox;
                    rows: [
                        row([Grid {
                            border: 0
                            growRows: [1]
                            rows: [
                                row([listLabel, Cell {content: widgetList, hspan: 2, prefHeight: 200}]),
                                row([jarLabel, jarField, browseButton])
                            ]
                        }]),
                        row([box = HBox {
                            translateX: bind grid.getPrefWidth(-1) - grid.border * 2 - box.boundsInLocal.width
                            content: [
                                SwingButton {text: "Add", action: add},
                                SwingButton {text: "Cancel", action: cancel}
                            ]
                        }])
                    ]
                }
            }
        };
    }
}
