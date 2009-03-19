/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package org.widgetfx.classloader;

import java.net.URL;
import java.net.URLClassLoader;
import java.net.URLStreamHandlerFactory;
import java.security.AllPermission;
import java.security.CodeSource;
import java.security.PermissionCollection;
import java.util.Arrays;

/**
 * @author Keith Combs
 * @author Stephen Chin
 */
public class WidgetFXClassLoader extends URLClassLoader {

    public WidgetFXClassLoader(URL[] urls, ClassLoader parent, URLStreamHandlerFactory factory) {
        super(urls, parent, factory);
    }

    public WidgetFXClassLoader(URL[] urls) {
        super(urls);
    }

    public WidgetFXClassLoader(URL[] urls, ClassLoader parent) {
        super(urls, parent);
    }

    @Override
    protected PermissionCollection getPermissions(CodeSource codesource) {
        System.out.println("getPermissions called with codesigners: " + (codesource.getCodeSigners() == null ? null : Arrays.asList(codesource.getCodeSigners())));
        System.out.println("getPermissions called with codecertificates: " + (codesource.getCertificates() == null ? null : Arrays.asList(codesource.getCertificates())));
        if (codesource.getCertificates() != null && codesource.getCertificates().length > 0) {
            AllPermission all = new AllPermission();
            PermissionCollection permissions = all.newPermissionCollection();
            permissions.add(all);
            return permissions;
        } else {
            return super.getPermissions(codesource);
        }
    }
}
