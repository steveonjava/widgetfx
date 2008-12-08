/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package org.widgetfx.communication;

/**
 *
 * @author schin
 */
public interface CommandProcessor {
    String hello();

    boolean addWidget(String jnlpUrl, double x, double y);
}
