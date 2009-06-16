/*
 * WidgetSecurityDialogFactory.fx
 *
 * Created on Apr 10, 2009, 3:08:42 PM
 */

package org.widgetfx.ui;

import org.jfxtras.stage.JFXDialog;
import javafx.scene.Scene;
import javafx.stage.Stage;
import javafx.stage.StageStyle;

import javafx.scene.text.Text;

import javafx.scene.paint.Color;

/**
 * @author Keith Combs
 * @author Stephen Chin
 */
public class WidgetSecurityDialogFactoryImpl extends WidgetSecurityDialogFactory {
    public-init var owner:Stage;

    var d:JFXDialog;

    override function securityWarning(companyName:String, publisherName:String, certificateUrl:String, trusted:Boolean):Boolean {
        var accepted:Boolean;
        def securityDialog:SecurityDialogUI = SecurityDialogUI {};
        (securityDialog.companyName as Text).content = companyName;
        (securityDialog.publisherName as Text).content = publisherName;
        (securityDialog.certificateUrl as Text).content = certificateUrl;
        if (trusted) {
            securityDialog.warningIcon.visible = false;
            securityDialog.warningText.visible = false;
            securityDialog.signatureInvalid.visible = false;
        } else {
            securityDialog.infoIcon.visible = false;
            securityDialog.securityText.visible = false;
            securityDialog.signatureValid.visible = false;
        }
        securityDialog.acceptButtonHover.visible = false;
        securityDialog.acceptButton.onMouseEntered = function(e) {
            securityDialog.acceptButtonHover.visible = true;
            if (securityDialog.acceptButton.pressed) {
                securityDialog.acceptButtonPressed.visible = true
            }
        }
        securityDialog.acceptButton.onMouseExited = function(e) {
            securityDialog.acceptButtonHover.visible = false;
            securityDialog.acceptButtonPressed.visible = false;
        }
        securityDialog.acceptButtonPressed.visible = false;
        securityDialog.acceptButton.onMousePressed = function(e) {securityDialog.acceptButtonPressed.visible = true}
        securityDialog.acceptButton.onMouseReleased = function(e) {
            securityDialog.acceptButtonPressed.visible = false;
            if (securityDialog.acceptButton.hover) {
                d.close();
                accepted = true;
            }
        }
        securityDialog.rejectButtonHover.visible = false;
        securityDialog.rejectButton.onMouseEntered = function(e) {
            securityDialog.rejectButtonHover.visible = true;
            if (securityDialog.rejectButton.pressed) {
                securityDialog.rejectButtonPressed.visible = true
            }
        }
        securityDialog.rejectButton.onMouseExited = function(e) {
            securityDialog.rejectButtonHover.visible = false;
            securityDialog.rejectButtonPressed.visible = false;
        }
        securityDialog.rejectButtonPressed.visible = false;
        securityDialog.rejectButton.onMousePressed = function(e) {securityDialog.rejectButtonPressed.visible = true}
        securityDialog.rejectButton.onMouseReleased = function(e) {
            securityDialog.rejectButtonPressed.visible = false;
            if (securityDialog.rejectButton.hover) {
                d.close();
                accepted = false;
            }
        }
        JFXDialog {
            style: StageStyle.TRANSPARENT
            owner: owner
            modal: true
            title: "Security Warning"
            scene: Scene {
                content: securityDialog
                fill: Color.TRANSPARENT
            }
            override var dialog on replace { // hack to get the dialog instance even though it is modal
                d = this;
            }
        }
        return accepted;
    }
}
