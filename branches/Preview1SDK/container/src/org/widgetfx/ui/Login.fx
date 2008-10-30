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
import javafx.application.*;
import javafx.scene.HorizontalAlignment;
import javafx.ext.swing.*;

/**
 * @author Stephen Chin
 */
public class Login {
    
    public attribute token:String;
    
    public attribute onLogin:function(username:String, password:String):Void;
    
    public attribute onCancel:function():Void;
    
    private attribute dialog:Dialog;
    
    private attribute username:String;
    
    private attribute password:String;
    
    postinit {
        var credentials = WidgetManager.getInstance().lookupCredentials(token);
        if (credentials != null) {
            onLogin(credentials[0], credentials[1]);
        } else {
            showDialog();
        }
    }
    
    private function login() {
        dialog.close();
        WidgetManager.getInstance().storeCredentials(token, username, password);
        if (onLogin != null) {
            onLogin(username, password);
        }
    }
    
    private function cancel() {
        dialog.close();
        if (onCancel != null) {
            onCancel();
        }
    }
    
    private function showDialog() {
        var usernameLabel = Label {text: "Username:", labelFor: usernameField}
        var usernameField = TextField {text: bind username with inverse, hmin: 300, hmax: 300, action: login};
        // todo - switch this to use a password field
        var passwordLabel = Label {text: "Password:", labelFor: usernameField}
        var passwordField = TextField {text: bind password with inverse, hmin: 300, hmax: 300, action: login};

        dialog = Dialog {
            title: "Login"
            visible: true
            resizable: false
            icons: WidgetFXConfiguration.getInstance().widgetFXIcon16s
            closeAction: cancel
            stage: Stage {
                content: ComponentView {
                    component: BorderPanel {
                        center: ClusterPanel {
                            vcluster: SequentialCluster {
                                content: [
                                    ParallelCluster {
                                        content: [
                                            usernameLabel,
                                            usernameField
                                        ]
                                    },
                                    ParallelCluster {
                                        content: [
                                            passwordLabel,
                                            passwordField
                                        ]
                                    }
                                ]
                            },
                            hcluster: SequentialCluster {
                                content: [
                                    ParallelCluster {
                                        content: [
                                            usernameLabel,
                                            passwordLabel
                                        ]
                                    },
                                    ParallelCluster {
                                        content: [
                                            usernameField,
                                            passwordField
                                        ]
                                    }
                                ]
                            }
                        }
                        bottom: FlowPanel {
                            alignment: HorizontalAlignment.RIGHT
                            content: [
                                Button {
                                    text: "Login"
                                    action: login
                                },
                                Button {
                                    text: "Cancel"
                                    action: cancel
                                }
                            ]
                        }
                    }
                }
            }
        };
    }
}
