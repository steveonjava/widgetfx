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
package org.widgetfx.stage;

import com.sun.javafx.stage.WindowStageDelegate$Intf;
import java.awt.Color;
import java.awt.Frame;
import java.awt.Graphics;
import java.awt.Window;
import javafx.stage.Stage$Intf;
import javax.swing.JDialog;
import javax.swing.JRootPane;

/**
 * @author Stephen Chin
 * @author Keith Combs
 */
public class WindowHelper {
    private static final boolean isMac() {
        return "Mac OS X".equals(System.getProperty("os.name"));
    }
    
    /**
     * This method retrieves a window from a stage delegate object, effectively working around
     * JavaFX permissions via a direct Java call to the code generated method.
     * 
     * @param delegate A WindowStageDelegate or subclass JavaFX object
     * @return The current value of the window var
     */
    public static Window extractWindow(WindowStageDelegate$Intf delegate) {
        return delegate.get$window().get();
    }
    
    /**
     * This method retrieves a window from a stage delegate object, effectively working around
     * JavaFX permissions via a direct Java call to the code generated method.
     * 
     * @param delegate A WindowStageDelegate or subclass JavaFX object
     * @return The current value of the window var
     */
    public static Window extractWindow(Stage$Intf stage) {
        return extractWindow((WindowStageDelegate$Intf) stage.get$impl_stageDelegate().get());
    }
    
    public static JDialog createJDialog(Frame owner) {
        JDialog dialog;
        if (isMac()) {
            dialog = new JDialog(owner) {
                @Override
                protected JRootPane createRootPane() {
                    JRootPane rp = new JRootPane() {
                        @Override
                        public void paint(Graphics g) {
                            g.clearRect(0, 0, getWidth(), getHeight());
                            super.paint(g);
                        }
                    };
                    rp.setOpaque(true);
                    return rp;
                }
            };
        }
        else {
            dialog = new JDialog(owner);
        }
        dialog.setBackground(Color.WHITE);
        return dialog;
    }
}
