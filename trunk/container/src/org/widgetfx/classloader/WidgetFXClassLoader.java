/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package org.widgetfx.classloader;

import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.lang.reflect.InvocationTargetException;
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
import java.security.cert.X509Certificate;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.FutureTask;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.security.auth.x500.X500Principal;
import javax.swing.SwingUtilities;
import org.widgetfx.ui.WidgetSecurityDialogFactory;

/**
 * @author Keith Combs
 * @author Stephen Chin
 */
public class WidgetFXClassLoader extends URLClassLoader {

    WidgetSecurityDialogFactory dialogFactory;
    private static final Object lock = new Object();
    private static int lockCount;
    private static KeyStore ks;
    private static List<Certificate> rejectedCerts = new ArrayList<Certificate>();

    public WidgetFXClassLoader(URL[] urls, ClassLoader parent, URLStreamHandlerFactory factory, WidgetSecurityDialogFactory dialogFactory) {
        super(urls, parent, factory);
        this.dialogFactory = dialogFactory;
    }

    public WidgetFXClassLoader(URL[] urls, WidgetSecurityDialogFactory dialogFactory) {
        super(urls);
        this.dialogFactory = dialogFactory;
    }

    public WidgetFXClassLoader(URL[] urls, ClassLoader parent, WidgetSecurityDialogFactory dialogFactory) {
        super(urls, parent);
        this.dialogFactory = dialogFactory;
    }

    boolean showDialog(final String companyName, final String publisherName, final String certificateUrl, final boolean trusted) throws InterruptedException, InvocationTargetException {
        FutureTask<Boolean> future = new FutureTask<Boolean>(new Callable<Boolean>() {

            @Override
            public Boolean call() {
                return dialogFactory.securityWarning(companyName, publisherName, certificateUrl, trusted);
            }
        });
        if (SwingUtilities.isEventDispatchThread()) {
            future.run();
        } else {
            SwingUtilities.invokeAndWait(future);
        }
        try {
            return future.get();
        } catch (ExecutionException ex) {
            Logger.getLogger(WidgetFXClassLoader.class.getName()).log(Level.SEVERE, null, ex);
            return false;
        }
    }

    @Override
    protected PermissionCollection getPermissions(CodeSource codesource) {
        synchronized (lock) {
            try {
                String trustedCerts = System.getProperty("deployment.user.security.trusted.certs");
                if (lockCount++ == 0) {
                    ks = KeyStore.getInstance(KeyStore.getDefaultType());
                    FileInputStream fis = new FileInputStream(trustedCerts);
                    try {
                        ks.load(fis, null);
                    } finally {
                        fis.close();
                    }
                }
                Certificate[] certificates = codesource.getCertificates();
                if (certificates != null && certificates.length > 0) {
                    for (Certificate cert : certificates) {
                        if (!(cert instanceof X509Certificate)) {
                            continue;
                        }
                        X509Certificate x509 = (X509Certificate) cert;
                        String alias = ks.getCertificateAlias(cert);
                        boolean trusted = alias != null && ks.isCertificateEntry(alias);
                        if (!trusted) {
                            for (Certificate rejected : rejectedCerts) {
                                if (rejected.equals(cert)) {
                                    return super.getPermissions(codesource);
                                }
                            }
                            boolean valid = true;
                            try {
                                x509.checkValidity();
                            } catch (CertificateException e) {
                                valid = false;
                            }
                            URL location = codesource.getLocation();
                            URL host = new URL(location.getProtocol(), location.getHost(), location.getPort(), "");
                            String subject = getCommonName(x509.getSubjectX500Principal());
                            String issuer = getCommonName(x509.getIssuerX500Principal());
                            if (showDialog(subject, issuer, host.toString(), valid)) {
                                alias = "deploymentusercert$tsflag-" + System.currentTimeMillis();
                                ks.setCertificateEntry(alias, cert);
                                FileOutputStream fos = new FileOutputStream(trustedCerts);
                                try {
                                    ks.store(fos, new char[0]);
                                } finally {
                                    fos.close();
                                }
                            } else {
                                rejectedCerts.add(cert);
                                return super.getPermissions(codesource);
                            }
                        }
                    }
                    AllPermission all = new AllPermission();
                    PermissionCollection permissions = all.newPermissionCollection();
                    permissions.add(all);
                    return permissions;
                }
            } catch (InterruptedException ex) {
                Logger.getLogger(WidgetFXClassLoader.class.getName()).log(Level.SEVERE, null, ex);
            } catch (InvocationTargetException ex) {
                Logger.getLogger(WidgetFXClassLoader.class.getName()).log(Level.SEVERE, null, ex);
            } catch (IOException ex) {
                Logger.getLogger(WidgetFXClassLoader.class.getName()).log(Level.SEVERE, null, ex);
            } catch (NoSuchAlgorithmException ex) {
                Logger.getLogger(WidgetFXClassLoader.class.getName()).log(Level.SEVERE, null, ex);
            } catch (CertificateException ex) {
                Logger.getLogger(WidgetFXClassLoader.class.getName()).log(Level.SEVERE, null, ex);
            } catch (KeyStoreException ex) {
                Logger.getLogger(WidgetFXClassLoader.class.getName()).log(Level.SEVERE, null, ex);
            } finally {
                lockCount--;
            }
        }
        return super.getPermissions(codesource);
    }

    private String getCommonName(X500Principal principal) {
        String principalDN = principal.toString();
        String[] parts = principalDN.split(", ");
        String commonName = principalDN;
        for (String part : parts) {
            if (part.startsWith("CN=")) {
                commonName = part.substring(3);
            }
        }
        return commonName;
    }
}
