/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package org.widgetfx.install;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * @author Stephen Chin
 * @author Keith Combs
 */
public class InstallUtil {
    
    private static final String home = System.getProperty("user.home");
    
    private static final File windowsShortcut = new File(home, "/Start Menu/Programs/Startup/WidgetFX.url");
    
    public static void copyStartupFile() {
        try {
            OutputStream destination = null;
            InputStream source = null;
            try {
                source = InstallUtil.class.getResourceAsStream("WidgetFX.url");
                destination = (new FileOutputStream(windowsShortcut));
                byte[] buf = new byte[1024];
                int i = 0;
                while ((i = source.read(buf)) != -1) {
                    destination.write(buf, 0, i);
                }
            } finally {
                if (source != null) {
                    source.close();
                }
                if (destination != null) {
                    destination.close();
                }
            }
        } catch (IOException ex) {
            Logger.getLogger(InstallUtil.class.getName()).log(Level.SEVERE, null, ex);
        }
    }
    
    public static void deleteStartupFile() {
        windowsShortcut.delete();
    }
}
