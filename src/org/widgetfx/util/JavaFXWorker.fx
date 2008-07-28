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
 * @author Stephen Chin
 */
public class JavaFXWorker extends AbstractAsyncOperation {
    private attribute worker:SwingWorker;
    
    public attribute inBackground: function():Object;
    
    public attribute result: Object;
    
    public function cancel():Void {
        if (worker.cancel(true)) {
            listener.onCancel();
        }
    }
    
    function onCompletion(value: Object) {
        result = value;
    }

    function start():Void {
        worker = ObjectSwingWorker {
            public function doInBackground():Object {
                return inBackground();
            }
            
            public function done():Void {
                try {
                    listener.onCompletion(get());
                } catch (e1:InterruptedException) {
                    listener.onCancel();
                } catch (e3:CancellationException) {
                    listener.onCancel();
                } catch (e2:ExecutionException) {
                    listener.onException(e2);
                }
            }
        };
        worker.execute();
    }
}
