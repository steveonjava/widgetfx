/*
 * WidgetSecurityDialogFactory.fx
 *
 * Created on Apr 10, 2009, 3:08:42 PM
 */

package org.widgetfx.ui;

import org.jfxtras.stage.JFXDialog;
import javafx.scene.Scene;
import javafx.scene.paint.Color;
import javafx.scene.shape.Rectangle;
import javafx.stage.Stage;
import javafx.stage.StageStyle;

/**
 * @author Keith Combs
 * @author Stephen Chin
 */
public class WidgetSecurityDialogFactoryImpl extends WidgetSecurityDialogFactory {
    public-init var owner:Stage;

    override function securityWarning(message:String):Boolean {
        var dialog:JFXDialog = JFXDialog {
            style: StageStyle.TRANSPARENT
            owner: owner
            modal: true
            title: "Security Warning"
            scene: Scene {
                content: SecurityDialogUI {
                    onMousePressed: function(e) {
                        dialog.close();
                    }
                }
            }
        }
        return true;
    }
}
