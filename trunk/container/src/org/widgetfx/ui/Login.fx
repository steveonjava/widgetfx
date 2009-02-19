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

import org.widgetfx.*;
import javafx.ext.swing.*;

/**
 * @author Stephen Chin
 */
public class Login {
    
    public-init var token:String;
    
    public-init var forceLogin:Boolean;
    
    public-init var onLogin:function(username:String, password:String):Void;
    
    public-init var onCancel:function():Void;
    
//    var dialog:Dialog;
    
    var username:String;
    
    var password:String;
    
    postinit {
        var credentials = if (forceLogin) null else WidgetManager.getInstance().lookupCredentials(token);
        if (credentials != null) {
            onLogin(credentials[0], credentials[1]);
        } else {
            showDialog();
        }
    }
    
    function login() {
//        dialog.close();
        WidgetManager.getInstance().storeCredentials(token, username, password);
        if (onLogin != null) {
            onLogin(username, password);
        }
    }
    
    function cancel() {
//        dialog.close();
        if (onCancel != null) {
            onCancel();
        }
    }
    
    function showDialog() {
//        var usernameLabel = Label {text: "Username:", labelFor: usernameField}
//        var usernameField = TextField {text: bind username with inverse, hmin: 300, hmax: 300, action: login};
        // todo - switch this to use a password field
//        var passwordLabel = Label {text: "Password:", labelFor: usernameField}
//        var passwordField = TextField {text: bind password with inverse, hmin: 300, hmax: 300, action: login};

        // todo - need a dialog hack
//        dialog = Dialog {
//            title: "Login"
//            visible: true
//            resizable: false
//            icons: WidgetFXConfiguration.getInstance().widgetFXIcon16s
//            closeAction: cancel
//            stage: Stage {
//                content: ComponentView {
//                    component: BorderPanel {
//                        center: ClusterPanel {
//                            vcluster: SequentialCluster {
//                                content: [
//                                    ParallelCluster {
//                                        content: [
//                                            usernameLabel,
//                                            usernameField
//                                        ]
//                                    },
//                                    ParallelCluster {
//                                        content: [
//                                            passwordLabel,
//                                            passwordField
//                                        ]
//                                    }
//                                ]
//                            },
//                            hcluster: SequentialCluster {
//                                content: [
//                                    ParallelCluster {
//                                        content: [
//                                            usernameLabel,
//                                            passwordLabel
//                                        ]
//                                    },
//                                    ParallelCluster {
//                                        content: [
//                                            usernameField,
//                                            passwordField
//                                        ]
//                                    }
//                                ]
//                            }
//                        }
//                        bottom: FlowPanel {
//                            alignment: HorizontalAlignment.RIGHT
//                            content: [
//                                Button {
//                                    text: "Login"
//                                    action: login
//                                },
//                                Button {
//                                    text: "Cancel"
//                                    action: cancel
//                                }
//                            ]
//                        }
//                    }
//                }
//            }
//        };
    }
}
