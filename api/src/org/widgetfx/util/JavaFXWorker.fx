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
package org.widgetfx.util;

import java.lang.InterruptedException;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.CancellationException;
import java.lang.Object;
import javafx.async.AbstractAsyncOperation;
import javax.swing.SwingWorker;

/**
 * SwingWorker equivalent for JavaFX Script to allow execution of asynchronous
 * operations in the background with notification and completion callbacks
 * on the Event Dispatch thread.
 * <p>
 * Here is an example that will load an Image and set it to a variable when the
 * load is completed:<blockquote><pre>
 * var currentImage:Image;
 * var worker = JavaFXWorker {
 *     inBackground: function() {
 *         return Image {url: currentFile.toURL().toString(), height: imageHeight};
 *     }
 *     onDone: function(result) {
 *         currentImage = result as Image;
 *     }
 * }
 * </pre></blockquote>
 * <p>
 * Both the inBackground and onDone handlers are required to be set.  Upon initialization
 * the worker will automatically start execution on a background thread and can be
 * later stopped by calling cancel.  Any results of execution in the background thread
 * will be saved to the result var and also passed in to the onDone handler.
 *
 * @author Stephen Chin
 */
public class JavaFXWorker {
    var worker:SwingWorker;
    
    /**
     * Function that will be executed on a background thread.  If an exception is
     * thrown while executing this function the failed var will be set to true
     * and failedText will be set to the exception message.
     * <p>
     * Since this method is executed asynchronous to other UI operations, it is not
     * safe to make calls that will modify the UI state.  This includes most JavaFX
     * Script library operations.
     * <p>
     * Failure to set this var will result in an NPE.
     */
    public-init var inBackground: function():Object;
    
    /**
     * Function that will be called once inBackground completes.  The result of the
     * background function will be passed in to the result parameter when this function
     * is called.
     * <p>
     * This function is guaranteed to be called on the Event Dispatch thread, and
     * can safely make changes to the UI state.
     * <p>
     * Failure to set this attribute will result in an NPE.
     */
    public-init var onDone: function(result:Object):Void;
    
    /**
     * Function that will be called if inBackground fails due to an exception.  The
     * exception is passed in as a parameter when this function is called, and the
     * attributes failed and failureText will be set to 'true' and the message of the
     * exception, respectively.
     * <p>
     * This function is guaranteed to be called on the Event Dispatch thread, and
     * can safely make changes to the UI state.
     * <p>
     * This var may be left null if no special handling of exceptions is required.
     */
    public-init var onFailure: function(e:ExecutionException):Void;

    /**
     * This var gets set to the result returned by the inBackground method
     * if it is successful, and will also be passed in to the onDone handler.
     */
    public-read var result: Object;
    
    /**
     * Immediately cancels the background thread if it is executing by throwing
     * an interruped exception.
     */
    public function cancel():Void {
        worker.cancel(true);
    }
    
    init {
        start();
    }
    
    function start():Void {
        worker = ObjectSwingWorker {
            override function doInBackground():Object {
                return inBackground();
            }
            
            override function done():Void {
                try {
                    onDone(get());
                } catch (e1:InterruptedException) {
                    // ignore
                } catch (e3:CancellationException) {
                    // ignore
                } catch (e2:ExecutionException) {
                    if (onFailure != null) {
                        onFailure(e2);
                    }
                }
            }
        };
        worker.execute();
    }
}
