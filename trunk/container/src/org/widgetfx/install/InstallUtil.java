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
package org.widgetfx.install;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.logging.Level;
import java.util.logging.Logger;
import com.sun.deploy.Environment;
import com.sun.deploy.util.WinRegistry;
import com.sun.deploy.config.Config;

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
    
    public static String getStartupFolder(){
        if (isWindows){
            // from WinInstallHandler
            int i = -2147483647;
            String str = "";

            if (Environment.isSystemCacheMode()) {
                i = -2147483646;
                str = "Common ";
            }
            return WinRegistry.getString(i, "Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Shell Folders", str + "Startup");
        } else {
            return "";
        }
    }

    public static void installShortcut(String path, String name, String desc, String app, String args, String dir, String icon){
        Config.getInstance().installShortcut(path, name, desc, app, args, dir, icon);
    }

}