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
package org.widgetfx.ui;

import org.widgetfx.*;
import org.widgetfx.stage.*;
import java.io.File;
import javafx.ext.swing.*;
import javafx.scene.*;
import javafx.scene.shape.*;
import javafx.scene.paint.*;
import javafx.stage.*;
import javax.swing.JFileChooser;
import javax.swing.filechooser.FileFilter;

/**
 * @author Stephen Chin
 */
public class AddWidgetDialog {
    
    public-init var addHandler:function(jnlpUrl:String):Void;
    
    public-init var cancelHandler:function():Void;
    
    public-init var owner:Stage;
    
    var jnlpUrl:String;
    
    var dialog:Dialog;
    
    postinit {
        showDialog();
    }
    
//    var selected:ListItem on replace {
//        jnlpUrl = selected.text;
//    }
    
    function add() {
        dialog.close();
        if (addHandler != null) {
            addHandler(jnlpUrl);
        }
    }
    
    function cancel() {
        dialog.close();
        if (cancelHandler != null) {
            cancelHandler();
        }
    }
    
    function showDialog() {
//        var widgetList = List {
//            selectedItem: bind selected with inverse
//            items: for (url in WidgetManager.getInstance().recentWidgets) ListItem {
//                text: url
//            }
//        }
//        var listLabel = Label {text: "Recent Widgets:", labelFor: widgetList}
//        var jarField = TextField {text: bind jnlpUrl with inverse, hmin: 300, hmax: 300, action: add};
//        var jarLabel = Label {text: "Widget URL:", labelFor: jarField};
//        var browsebutton:Button = Button {
//            text: "Browse...";
//            action: function() {
//                var chooser = new JFileChooser(jnlpUrl);
//                chooser.setFileFilter(FileFilter {
//                    public function accept(f:File):Boolean {
//                        return f.isDirectory() or f.getName().toLowerCase().endsWith(".jnlp") or f.getName().toLowerCase().endsWith(".swf") or f.getName().toLowerCase().endsWith(".swfi");
//                    }
//                    public function getDescription():String {
//                        return "WidgetFX Widget (JNLP or SWF)"
//                    }
//                });
//                var returnVal = chooser.showOpenDialog(browsebutton.getJButton());
//                if (returnVal == JFileChooser.APPROVE_OPTION) {
//                    jnlpUrl = chooser.getSelectedFile().toURL().toString();
//                }
//            }
//        }

        dialog = Dialog {
            title: "Add Widget"
            resizable: false
            icons: WidgetFXConfiguration.getInstance().widgetFXIcon16s
            onClose: cancel
            owner: owner
            scene: Scene {
                content: Circle {radius: 100, fill: Color.BLUE}
//                content: ComponentView {
//                    component: BorderPanel {
//                        center: ClusterPanel {
//                            vcluster: SequentialCluster {
//                                content: [
//                                    ParallelCluster {
//                                        content: [
//                                            listLabel,
//                                            widgetList
//                                        ]
//                                    },
//                                    ParallelCluster {
//                                        content: [
//                                            jarLabel,
//                                            jarField,
//                                            browsebutton
//                                        ]
//                                    }
//                                ]
//                            },
//                            hcluster: SequentialCluster {
//                                content: [
//                                    ParallelCluster {
//                                        content: [
//                                            listLabel,
//                                            jarLabel
//                                        ]
//                                    },
//                                    ParallelCluster {
//                                        content: [
//                                            widgetList,
//                                            SequentialCluster {
//                                                content: [
//                                                    jarField,
//                                                    browsebutton
//                                                ]
//                                            }
//                                        ]
//                                    }
//                                ]
//                            }
//                        }
//                        bottom: FlowPanel {
//                            alignment: HorizontalAlignment.RIGHT
//                            content: [
//                                Button {
//                                    text: "Add"
//                                    action: add
//                                },
//                                Button {
//                                    text: "Cancel"
//                                    action: cancel
//                                }
//                            ]
//                        }
//                    }
//                }
            }
        };
    }
}
