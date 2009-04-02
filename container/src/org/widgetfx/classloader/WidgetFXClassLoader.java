/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package org.widgetfx.classloader;

import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.net.URL;
import java.net.URLClassLoader;
import java.net.URLStreamHandlerFactory;
import java.security.AllPermission;
import java.security.CodeSource;
import java.security.KeyStore;
import java.security.KeyStoreException;
import java.security.NoSuchAlgorithmException;
import java.security.PermissionCollection;
import java.security.cert.Certificate;
import java.security.cert.CertificateException;
import java.util.Arrays;
import java.util.logging.Level;
import java.util.logging.Logger;

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
        try {
            KeyStore ks = KeyStore.getInstance(KeyStore.getDefaultType());
            String trustedCerts = System.getProperty("deployment.user.security.trusted.certs");
            System.out.println(trustedCerts);
            FileInputStream fis = new FileInputStream(trustedCerts);
            try {
                ks.load(fis, null);
            } finally {
                fis.close();
            }
            Certificate[] certificates = codesource.getCertificates();
            if (certificates != null && certificates.length > 0) {
                for (Certificate cert : certificates) {
                    String alias = ks.getCertificateAlias(cert);
                    boolean trusted = alias != null && ks.isCertificateEntry(alias);
                    if (!trusted) {
                        alias = "deploymentusercert$tsflag-" + System.currentTimeMillis();
                        ks.setCertificateEntry(alias, cert);
                        System.out.println("storing key with alias = " + alias);
                        FileOutputStream fos = new FileOutputStream(trustedCerts);
                        try {
                            ks.store(fos, new char[0]);
                        } finally {
                            fos.close();
                        }
                    }
                }
                AllPermission all = new AllPermission();
                PermissionCollection permissions = all.newPermissionCollection();
                permissions.add(all);
                return permissions;
            }
        } catch (IOException ex) {
            Logger.getLogger(WidgetFXClassLoader.class.getName()).log(Level.SEVERE, null, ex);
        } catch (NoSuchAlgorithmException ex) {
            Logger.getLogger(WidgetFXClassLoader.class.getName()).log(Level.SEVERE, null, ex);
        } catch (CertificateException ex) {
            Logger.getLogger(WidgetFXClassLoader.class.getName()).log(Level.SEVERE, null, ex);
        } catch (KeyStoreException ex) {
            Logger.getLogger(WidgetFXClassLoader.class.getName()).log(Level.SEVERE, null, ex);
        }
        return super.getPermissions(codesource);
    }
}
