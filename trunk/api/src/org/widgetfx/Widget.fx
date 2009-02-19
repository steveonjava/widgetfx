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
package org.widgetfx;

import org.widgetfx.config.Configuration;
import java.lang.NoClassDefFoundError;
import java.lang.Throwable;
import java.net.URL;
import java.net.URLClassLoader;
import java.util.regex.Pattern;
import javafx.lang.FX;
import javafx.scene.control.*;
import javax.jnlp.BasicService;
import javax.jnlp.ServiceManager;

/**
 * Enables or disabled auto launch facility for testing widgets.  The default value
 * is true to facilitate simple testing of widgets and debugging of deployed widgets.
 * <p>
 * When autoLaunch is set to true, a Widget Runner will be invoked to run this widget
 * in a different process.  The codebase and launchHref will be used to pass as
 * parameters to the Widget Runner.  Once the Widget Runner has been started, this
 * process will exit.
 */
public var autoLaunch = true;

/**
 * Instance class for Widgets that can be deployed in the WidgetFX container.
 * This class extends Stage so that any valid Widget can also be easily
 * tested or deployed as an Applet.
 * <p>
 * In addition to the functionality provided by the Stage base class,
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
 * import javafx.scene.Scene;
 * import javafx.scene.shape.Ellipse;
 * import javafx.scene.paint.Color;
 * import javafx.stage.Stage;
 * var widget:Widget;
 * widget = Widget {
 *     width = 100;
 *     height = 100;
 *     skin: Skin {
 *         scene: Ellipse {
 *             centerX: bind widget.width / 2
 *             centerY: bind widget.height / 2
 *             radiusX: bind widget.width / 2
 *             radiusY: bind widget.height / 2
 *             fill: Color.RED
 *         }
 *     }
 * }
 * </pre></blockquote>
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
public class Widget extends Control {

    /**
    * The external url to the widget runner process that will be launched.
     */
    def WIDGET_RUNNER_URL = "http://widgetfx.org/dock/runner.jnlp";
    
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
    public var aspectRatio: Number = 0;
    
    /**
    * Configuration object for widgets.  This must be set in order to persist
     * state between invocations of the widget container.  See the {@link Configuration}
     * class for more information.
     */
    public-init protected var configuration: Configuration;

    /**
    * All widgets extend Resizable, and by default can be resized by the user,
     * but if intend the widget to be displayed at a fixed size, this variable
     * can be set to false to remove the resize controls.
     */
    public-init protected var resizable: Boolean = true;
    
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
    public-init protected var onResize: function(width:Number, height:Number):Void;
    
    /**
    * Event handler called when a widget is docked.  This can be used to change
     * the presentation of a widget to something more suitable to a space limited
     * dock.
     */
    public-init protected var onDock: function():Void;

    /**
    * Event handler called when a widget is undocked.  This can be used to change
     * the presentation of a widget to reflect the larger space available for
     * display.
     */
    public-init protected var onUndock: function():Void;

    /**
    * WARNING: NOT YET IMPLEMENTED
     * <p>
     * Allows multiple instances of this widget to be added to the same dock with
     * unique configuration options.  When launched from a url, a new instance will
     * only be added if it has configuration options and those configuration options
     * are different than all currently added widgets of the same type.
     * <p>
     * The default value is false, in which case only one instance of this widget
     * can be added to the dock.
     */
    public-init protected var multiInstance = false;

    /**
    * Highlights the border of the widget, indicating it needs attention.
     * <p>
     * This is a runtime property and can be enabled or disabled at any time.
     */
    public var alert = false;
    
    /**
    * The href used to launch the Widget Runner process.  The default value is
     * the same as the jar for the main class and must be updated if you use
     * a different jnlp filename.
     */
    public-init protected var launchHref: String;
    
    init {
        if (autoLaunch) {
            try {
                var basicService =
                ServiceManager.lookup("javax.jnlp.BasicService") as BasicService;
                if (launchHref.length() > 0) {
                    var classLoader =
                    getClass().getClassLoader() as java.net.URLClassLoader;
                    var urls = classLoader.getURLs();
                    var jarUrl = urls[0].toString();
                    var matcher = Pattern.compile("/([^/]*)\\.jar").matcher(jarUrl);
                    launchHref = if (matcher.find()) {
                        "{matcher.group(1)}.jnlp"
                    } else {
                        "launch.jnlp"
                    }
                }
                basicService.showDocument(new URL("{WIDGET_RUNNER_URL}?arg={basicService.getCodeBase()}{launchHref}"));
                FX.exit();
            } catch (e1:NoClassDefFoundError) {
                // not running in Web Start, continue running the applet
            
            
            } catch (e2:Throwable) {
                println("Unable to launch Widget Runner");
                e2.printStackTrace();
            }
        }
    }
}
