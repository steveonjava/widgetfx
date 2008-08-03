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
import javafx.application.*;
import javafx.scene.HorizontalAlignment;
import javafx.ext.swing.*;
import javax.swing.JFileChooser;

/**
 * @author Stephen Chin
 */
public class AddWidgetDialog {
    
    public attribute jarUrl:String;
    public attribute className:String;

    public function showDialog() {
        var jarField = TextField {text: bind jarUrl with inverse, hmin: 300, hmax: 300};
        var jarLabel = Label {text: "Jar URL:", labelFor: jarField};
        var browsebutton:Button = Button {
            text: "Browse...";
            action: function() {
                var chooser:JFileChooser = new JFileChooser(jarUrl);
                var returnVal = chooser.showOpenDialog(browsebutton.getJButton());
                if (returnVal == JFileChooser.APPROVE_OPTION) {
                    jarUrl = chooser.getSelectedFile().toURL().toString();
                }
            }
        }
        var classField = TextField {text: bind className with inverse, hmin: 300, hmax: 400};
        var classLabel = Label {text: "Class Name:", labelFor: classField};

        var dialog:Dialog = Dialog {
            title: "Add Widget"
            visible: true
            resizable: false
            stage: Stage {
                content: ComponentView {
                    component: BorderPanel {
                        center: ClusterPanel {
                            vcluster: SequentialCluster {
                                content: [
                                    ParallelCluster {
                                        content: [
                                            jarLabel,
                                            jarField,
                                            browsebutton
                                        ]
                                    },
                                    ParallelCluster {
                                        content: [
                                            classLabel,
                                            classField
                                        ]
                                    }
                                ]
                            }
                            hcluster: SequentialCluster {
                                content: [
                                    ParallelCluster {
                                        content: [
                                            jarLabel,
                                            classLabel
                                        ]
                                    },
                                    ParallelCluster {
                                        content: [
                                            SequentialCluster {
                                                content: [jarField, browsebutton]
                                            },
                                            classField
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
                                        WidgetManager.getInstance().addWidget([jarUrl], className);
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
