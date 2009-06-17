/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package org.widgetfx.classloader;

import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.lang.reflect.InvocationTargetException;
import java.net.URL;
import java.net.URLClassLoader;
import java.net.URLStreamHandlerFactory;
import java.security.AllPermission;
import java.security.CodeSigner;
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

    private static final String systemCACerts = System.getProperty("deployment.system.security.cacerts");
    private static final String userCACerts = System.getProperty("deployment.user.security.trusted.cacerts");
    private static final String systemCerts = System.getProperty("deployment.system.security.trusted.certs");
    private static final String userCerts = System.getProperty("deployment.user.security.trusted.certs");

    private static final Object lock = new Object();
    private static int lockCount;

    private static KeyStore systemCAKS;
    private static KeyStore userCAKS;
    private static KeyStore systemKS;
    private static KeyStore userKS;
    private static List<Certificate> rejectedCerts = new ArrayList<Certificate>();

    private String widgetName;
    private WidgetSecurityDialogFactory dialogFactory;

    public WidgetFXClassLoader(String widgetName, URL[] urls, ClassLoader parent, URLStreamHandlerFactory factory, WidgetSecurityDialogFactory dialogFactory) {
        super(urls, parent, factory);
        this.dialogFactory = dialogFactory;
        this.widgetName = widgetName;
    }

    public WidgetFXClassLoader(String widgetName, URL[] urls, WidgetSecurityDialogFactory dialogFactory) {
        super(urls);
        this.dialogFactory = dialogFactory;
        this.widgetName = widgetName;
    }

    public WidgetFXClassLoader(String widgetName, URL[] urls, ClassLoader parent, WidgetSecurityDialogFactory dialogFactory) {
        super(urls, parent);
        this.dialogFactory = dialogFactory;
        this.widgetName = widgetName;
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
                if (systemCAKS == null) {
                    systemCAKS = loadCerts(systemCACerts);
                    userCAKS = loadCerts(userCACerts);
                }
                if (lockCount++ == 0) {
                    systemKS = loadCerts(systemCerts);
                    userKS = loadCerts(userCerts);
                }
                CodeSigner[] codeSigners = codesource.getCodeSigners();
                if (codeSigners != null) {
                    for (CodeSigner signer : codeSigners) {
                        List<? extends Certificate> certificates = signer.getSignerCertPath().getCertificates();
                        X509Certificate x509 = (X509Certificate) certificates.get(0);
                        if ((userKS != null && userKS.getCertificateAlias(x509) != null) || (systemKS != null && systemKS.getCertificateAlias(x509) != null)) {
                            // valid certificate, check the rest of the signers
                            continue;
                        }
                        for (Certificate rejected : rejectedCerts) {
                            if (rejected.equals(x509)) {
                                throw new SecurityException("Certificate rejected by user");
                            }
                        }
                        boolean valid = checkValidity(x509);
                        Certificate root = certificates.get(certificates.size() - 1);
                        if ((systemCAKS == null || systemCAKS.getCertificateAlias(root) == null) && (userCAKS == null || userCAKS.getCertificateAlias(root) == null)) {
                            valid = false;
                        }
                        String subject = getCommonName(x509.getSubjectX500Principal());
                        URL location = codesource.getLocation();
                        URL host = new URL(location.getProtocol(), location.getHost(), location.getPort(), "");
                        if (showDialog(widgetName, subject, host.toString(), valid)) {
                            writeUserCert(x509);
                        } else {
                            rejectedCerts.add(x509);
                            throw new SecurityException("Certificate rejected by user");
                        }
                    }
                    return grantAllPermissions();
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

    private boolean checkValidity(X509Certificate x509) {
        boolean valid;
        valid = true;
        try {
            x509.checkValidity();
        } catch (CertificateException e) {
            valid = false;
        }
        return valid;
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

    private PermissionCollection grantAllPermissions() {
        AllPermission all = new AllPermission();
        PermissionCollection permissions = all.newPermissionCollection();
        permissions.add(all);
        return permissions;
    }

    private KeyStore loadCerts(String certs) throws KeyStoreException, IOException, NoSuchAlgorithmException, CertificateException {
        KeyStore ks = KeyStore.getInstance(KeyStore.getDefaultType());
        FileInputStream fis;
        try {
            fis = new FileInputStream(certs);
            try {
                ks.load(fis, null);
            } finally {
                fis.close();
            }
            return ks;
        } catch (FileNotFoundException e) {
            return null;
        }
    }

    private void writeUserCert(X509Certificate x509) throws KeyStoreException, CertificateException, IOException, FileNotFoundException, NoSuchAlgorithmException {
        String alias = "deploymentusercert$tsflag-" + System.currentTimeMillis();
        userKS.setCertificateEntry(alias, x509);
        FileOutputStream fos = new FileOutputStream(userCerts);
        try {
            userKS.store(fos, new char[0]);
        } finally {
            fos.close();
        }
    }
}
