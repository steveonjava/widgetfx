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
package org.widgetfx.ui;

import org.widgetfx.*;
import java.io.File;
import javafx.application.*;
import javafx.scene.HorizontalAlignment;
import javafx.ext.swing.*;
import javax.swing.JFileChooser;
import javax.swing.filechooser.FileFilter;

/**
 * @author Stephen Chin
 */
public class AddWidgetDialog {
    
    public attribute jnlpUrl:String;
    
    private attribute selected:ListItem on replace {
        jnlpUrl = selected.text;
    }
    
    public function showDialog() {
        var widgetList = List {
            selectedItem: bind selected with inverse
            items: for (url in WidgetManager.getInstance().recentWidgets) ListItem {
                text: url
            }
        }
        var listLabel = Label {text: "Recent Widgets:", labelFor: widgetList}
        var jarField = TextField {text: bind jnlpUrl with inverse, hmin: 300, hmax: 300};
        var jarLabel = Label {text: "Widget URL:", labelFor: jarField};
        var browsebutton:Button = Button {
            text: "Browse...";
            action: function() {
                var chooser = new JFileChooser(jnlpUrl);
                chooser.setFileFilter(FileFilter {
                    public function accept(f:File):Boolean {
                        return f.isDirectory() or f.getName().toLowerCase().endsWith(".jnlp");
                    }
                    public function getDescription():String {
                        return "Java Network Launch Protocol (JNLP)"
                    }
                });
                var returnVal = chooser.showOpenDialog(browsebutton.getJButton());
                if (returnVal == JFileChooser.APPROVE_OPTION) {
                    jnlpUrl = chooser.getSelectedFile().toURL().toString();
                }
            }
        }

        var dialog:Dialog = Dialog {
            title: "Add Widget"
            visible: true
            resizable: false
            icons: Dock.getInstance().widgetFxIcon
            stage: Stage {
                content: ComponentView {
                    component: BorderPanel {
                        center: ClusterPanel {
                            vcluster: SequentialCluster {
                                content: [
                                    ParallelCluster {
                                        content: [
                                            listLabel,
                                            widgetList
                                        ]
                                    },
                                    ParallelCluster {
                                        content: [
                                            jarLabel,
                                            jarField,
                                            browsebutton
                                        ]
                                    }
                                ]
                            },
                            hcluster: SequentialCluster {
                                content: [
                                    ParallelCluster {
                                        content: [
                                            listLabel,
                                            jarLabel
                                        ]
                                    },
                                    ParallelCluster {
                                        content: [
                                            widgetList,
                                            SequentialCluster {
                                                content: [
                                                    jarField,
                                                    browsebutton
                                                ]
                                            }
                                        ]
                                    }
                                ]
                            }
                        }
                        bottom: FlowPanel {
                            alignment: HorizontalAlignment.RIGHT
                            content: [
                                Button {
                                    text: "Add"
                                    action: function() {
                                        WidgetManager.getInstance().addWidget(jnlpUrl);
                                        dialog.close();
                                    }
                                },
                                Button {
                                    text: "Cancel"
                                    action: function() {
                                        dialog.close();
                                    }
                                }
                            ]
                        }
                    }
                }
            }
        };
    }
}
