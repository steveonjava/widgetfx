/*
 * Main.fx
 *
 * Created on Aug 3, 2009, 5:44:36 AM
 */

package org.widgetfx.launcher;

import java.lang.Throwable;
import java.net.URL;

import javax.jnlp.BasicService;
import javax.jnlp.ServiceManager;
import javafx.stage.Alert;

import javax.jnlp.UnavailableServiceException;

/**
 * @author Steve
 */

/**
 * The external url to the WidgetFX Dock
 */
def WIDGET_DOCK_URL = "http://widgetfx.org/dock/launch.jnlp";

try {
    var basicService = ServiceManager.lookup("javax.jnlp.BasicService") as BasicService;
    basicService.showDocument(new URL(WIDGET_DOCK_URL));
    FX.exit();
} catch (e:UnavailableServiceException) {
    Alert.inform("Web Start Error", "Cannot launch the WidgetFX dock, because the JNLP service is unavailable.  Please install the latest version of Java Web Start.");
} catch (e2:Throwable) {
    Alert.inform("Fatal Error", "Cannot launch the WidgetFX dock due to the following exception: {e2.getMessage()}");
    e2.printStackTrace();
}
