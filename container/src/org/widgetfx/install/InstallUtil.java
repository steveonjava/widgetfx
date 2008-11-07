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
    private static final boolean isWindows = System.getProperty("os.name").contains("Windows");
    
    private static final String home = System.getProperty("user.home");
    
    private static final File windowsShortcut = new File(home, "/Start Menu/Programs/Startup/WidgetFX.lnk");
    
    public static boolean startupSupported() {
        return isWindows;
    }
    
    public static void copyStartupFile() {
        if (!isWindows) {
            return;
        }
        try {
            OutputStream destination = null;
            InputStream source = null;
            try {
                source = InstallUtil.class.getResourceAsStream("WidgetFX.lnk");
                destination = (new FileOutputStream(windowsShortcut));
                copyStream(source, destination);
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
        if (!isWindows) {
            return;
        }
        windowsShortcut.delete();
    }

    public static void copyStream(InputStream source, OutputStream destination) throws IOException {
        byte[] buf = new byte[1024];
        int i = 0;
        while ((i = source.read(buf)) != -1) {
            destination.write(buf, 0, i);
        }
    }
}
