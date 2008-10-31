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
package org.widgetfx;

import org.widgetfx.config.Configuration;
import java.awt.EventQueue;
import java.lang.Runnable;
import java.lang.System;
import java.lang.Throwable;
import java.net.URL;
import javafx.application.Application;
import javax.jnlp.BasicService;
import javax.jnlp.ServiceManager;

/**
 * Instance class for Widgets that can be deployed in the WidgetFX container.
 * This class extends Application so that any valid Widget can also be easily
 * tested or deployed as an Applet.
 * <p>
 * In addition to the functionality provided by the Application base class,
 * this class also supports additional properties specific to widgets to
 * control resizing, aspectRatio, and configuration.  There are also event
 * handler callbacks for resize and dock operations.
 * <p>
 * To create a widget that can be deployed in the WidgetFX container, you
 * need to create an instance of this class in a JavaFX file, and create a
 * JNLP file that refers to the compiled JavaFX class.
 * <p>
 * Sample JavaFX file for an ellipse widget:
 * <blockquote><pre>
 * import org.widgetfx.Widget;
 * import javafx.application.Stage;
 * import javafx.scene.geometry.Ellipse;
 * import javafx.scene.paint.Color;
 * var width = 100;
 * var height = 100;
 * widget = Widget {
 *     resizable: true
 *     stage: Stage {
 *         width: bind width with inverse;
 *         height: bind height with inverse;
 *         content: Ellipse {
 *             centerX: bind width / 2
 *             centerY: bind height / 2
 *             radiusX: bind width / 2
 *             radiusY: bind height / 2
 *             fill: Color.RED
 *         }
 *     }
 * }</pre></blockquote>
 * <p>
 * Sample JNLP file for the above widget:
 * <blockquote><pre>
 * &lt;?xml version="1.0" encoding="UTF-8"?&gt;
 * &lt;jnlp spec="1.0+" codebase="file:/C:/SampleWidget/" href="launch.jnlp"&gt;
 *     &lt;information&gt;
 *         &lt;title&gt;SampleWidget&lt;/title&gt;
 *     &lt;/information&gt;
 *     &lt;resources&gt;
 *         &lt;j2se version="1.6+"/&gt;
 *         &lt;jar href="lib/widgetfx-api.jar" download="eager"/&gt;
 *     &lt;/resources&gt;
 *     &lt;application-desc main-class="WidgetSample"/&gt;
 * &lt;/jnlp&gt;</pre></blockquote>
 *
 * For more information about creating widgets, please see the WidgetFX project page:<br>
 * <a href="http://code.google.com/p/widgetfx/">http://code.google.com/p/widgetfx/</a>
 *
 * @author Stephen Chin
 * @author Keith Combs
 */
public class Widget extends Application {
    /**
     * Whether or not this widget supports resizing.  Default is false to prevent
     * fixed size widgets from being resized.
     * <p>
     * To enable resizing of a widget, set this to true when instantiating your
     * widget instance.
     */
    public attribute resizable:Boolean = false;
    
    /**
     * Used to give widgets a fixed aspectRatio.  The default value of 0 allows
     * widgets to be resized without constraints.
     * <p>
     * Valid values to force an aspectRatio are any decimal values greater than 0.
     * Decimals greater than 1 will result in wide aspects and decimals between
     * 0 and 1 will result in tall aspects.  An easy way to set this is to use
     * a fraction as such:
     * <blockquote><pre>
     * aspectRatio: 4.0/3.0</pre></blockquote>
     * In this example, the width will be 4/3 greater than the height.
     */
    public attribute aspectRatio:Number = 0;
    
    /**
     * Configuration object for widgets.  This must be set in order to persist
     * state between invocations of the widget container.  See the {@link Configuration}
     * class for more information.
     */
    public attribute configuration:Configuration;
    
    /**
     * Event handler called on resize of a widget.  This method is always
     * called with the current value of stage.width and stage.height
     * as the parameters.
     * <p>
     * This is preferable to directly binding to stage.width and stage.height where
     * frequent updates would cause performance issues.  This method is guaranteed
     * to be called only once per resize operation regardless of the intermediate
     * values of stage.width and stage.height.
     */
    public attribute onResize:function(width:Integer, height:Integer):Void;
    
    /**
     * Event handler called when a widget is docked.  This can be used to change
     * the presentation of a widget to something more suitable to a space limited
     * dock.
     */
    public attribute onDock:function():Void;

    /**
     * Event handler called when a widget is undocked.  This can be used to change
     * the presentation of a widget to reflect the larger space available for
     * display.
     */
    public attribute onUndock:function():Void;
    
    /**
     * Enables or disabled auto launch facility for testing widgets.  The default value
     * is true to facilitate simple testing of widgets and debugging of deployed widgets.
     *
     * When autoLaunch is set to true, a Widget Runner will be invoked to run this widget
     * in a different process.  The codebase and launchHref will be used to pass as
     * parameters to the Widget Runner.  Once the Widget Runner has been started, this
     * process will exit.
     */
    protected attribute autoLaunch = true;
    
    /**
     * The href used to launch the Widget Runner process.  The default value is "launch.jnlp",
     * and must be updated if you use a different jnlp filename.
     */
    protected attribute launchHref = "launch.jnlp";
    
    postinit {
        // todo - replace with DeferredTask when it is safe to call it from the sandbox
        EventQueue.invokeLater(Runnable {
            public function run() {
                if (autoLaunch) {
                    try {
                        var basicService = ServiceManager.lookup("javax.jnlp.BasicService") as BasicService;
                        basicService.showDocument(new URL("http://widgetfx.org/dock/runner.jnlp?arg={basicService.getCodeBase()}{launchHref}"));
                        System.exit(0);
                    } catch (e:Throwable) {
                        // not running in Web Start, continue running the applet
                    }
                }
            }
        });
    }
}
