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

import javax.swing.*;
import javax.swing.event.PopupMenuListener;
import javax.swing.event.PopupMenuEvent;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;
import java.awt.geom.Ellipse2D;
import java.awt.image.BufferedImage;

/**
 * Based on a blog post from Alexander Potochkin at the following url:
 * http://weblogs.java.net/blog/alexfromsun/archive/2008/02/jtrayicon_updat.html
 * 
 * @author Alexander Potochkin
 * @author Stephen Chin
 * @author Keith Combs
 */
public class JXTrayIcon extends TrayIcon {
    private JPopupMenu menu;
    private static JDialog dialog;
    static {
        dialog = new JDialog((Frame) null, "TrayDialog");
        dialog.setUndecorated(true);
        dialog.setAlwaysOnTop(true);
    }
    
    private static PopupMenuListener popupListener = new PopupMenuListener() {
        @Override
        public void popupMenuWillBecomeVisible(PopupMenuEvent e) {
        }

        @Override
        public void popupMenuWillBecomeInvisible(PopupMenuEvent e) {
            dialog.setVisible(false);
        }

        @Override
        public void popupMenuCanceled(PopupMenuEvent e) {
            dialog.setVisible(false);
        }
    };

    public JXTrayIcon(Image image) {
        super(image);
        addMouseListener(new MouseAdapter() {
            @Override
            public void mousePressed(MouseEvent e) {
                showJPopupMenu(e);
            }

            @Override
            public void mouseReleased(MouseEvent e) {
                showJPopupMenu(e);
            }
        });
    }

    private void showJPopupMenu(MouseEvent e) {
        if (e.isPopupTrigger() && menu != null) {
            Dimension size = menu.getPreferredSize();
            int adjustedY = e.getY() - size.height;
            dialog.setLocation(e.getX(), adjustedY < 0 ? e.getY() : adjustedY);
            dialog.setVisible(true);
            menu.show(dialog.getContentPane(), 0, 0);
            // popup works only for focused windows
            dialog.toFront();
        }
    }

    public JPopupMenu getJPopupMenu() {
        return menu;
    }

    public void setJPopupMenu(JPopupMenu menu) {
        if (this.menu != null) {
            this.menu.removePopupMenuListener(popupListener);
        }
        this.menu = menu;
        menu.addPopupMenuListener(popupListener);
    }
    
} 
