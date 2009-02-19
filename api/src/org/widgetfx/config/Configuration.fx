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
package org.widgetfx.config;

import javafx.scene.Scene;

/**
 * This class provides an entry point for configuration capabilities of widgets.
 * It provides capabilities to show a configuration dialog, save properties
 * to disk, and load properties on startup.
 * <p>
 * Here is a simple example that persists a String property:<blockquote><pre>
 * var directoryName;
 * Configuration {
 *     properties: [
 *         StringProperty {
 *             name: "directoryName"
 *             value: bind directoryName with inverse
 *         }
 *     ]
 *     component: TextField {text: bind directoryName with inverse}
 *     onLoad: function() {
 *         loadDirectory(directoryName);
 *     }
 *     onSave: function() {
 *         loadDirectory(directoryName);
 *     }
 * }
 * </pre></blockquote>
 * <p>
 * Notice that a variable is used to bind the String Property with a bi-directional
 * bind.  This allows seamless bijection of the loaded value into and saved value
 * from the class and is a recommended practice.
 *
 * @author Stephen Chin
 * @author Keith Combs
 */
public class Configuration {
    /**
     * The scene that will be displayed in a configuration dialog for editing
     * properties of this widget.  If this is set to null configuration of the
     * associated widget will be disabled.
     */
    public var scene:Scene;
    
    /**
     * A list of properties that will be read and written for persistence.  This
     * array must be populated prior to load, because only existing properties
     * will have their values set.  Likewise, on save all the values in this
     * array will have their current values persisted.  For an example of how
     * to use this var, see the class documentation above.
     * <p>
     * In order to remain backwards compatible with older versions of persisted
     * configuration, it is recommended that property names are not reused for
     * different purposes.  This way the old property can be read in (or simply
     * ignored) for backwards compatibility, while new properties can be added
     * to handle additional requirements.
     */
    public var properties:Property[];
    
    /**
     * If set, this provides a load handler that will be called precisely once
     * after the widget configuration is loaded.
     */
    public-init var onLoad:function();
    
    /**
     * If set, this provides a save handler that will be called when the user
     * explicitly saves configuration by clicking on the "Save" button in the
     * configuration dialog, but before the properties are written to disk.
     * This will not be called for auto-save operations which can be enabled
     * per (@see Property}.
     */
    public-init var onSave:function();
}
