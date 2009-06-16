/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package org.widgetfx.ui;

/**
 *
 * @author kcombs
 */
public interface WidgetSecurityDialogFactory {
    boolean securityWarning(String companyName, String publisherName, String certificateUrl, boolean trusted);
}
