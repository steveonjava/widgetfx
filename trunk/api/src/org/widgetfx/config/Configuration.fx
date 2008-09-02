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
package org.widgetfx.config;

import javafx.ext.swing.Component;

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
     * The component that will be placed in a configuration dialog for editing
     * properties of this widget.  If this is set to null configuration of the
     * associated widget will be disabled.
     */
    public attribute component:Component;
    
    /**
     * A list of properties that will be read and written for persistence.  This
     * array must be populated prior to load, because only existing properties
     * will have their values set.  Likewise, on save all the values in this
     * array will have their current values persisted.  For an example of how
     * to use this attribute, see the class documentation above.
     * <p>
     * In order to remain backwards compatible with older versions of persisted
     * configuration, it is recommended that property names are not reused for
     * different purposes.  This way the old property can be read in (or simply
     * ignored) for backwards compatibility, while new properties can be added
     * to handle additional requirements.
     */
    public attribute properties:Property[];
    
    /**
     * If set, this provides a load handler that will be called precisely once
     * after the widget configuration is loaded.
     */
    public attribute onLoad:function();
    
    /**
     * If set, this provides a save handler that will be called when the user
     * explicitly saves configuration by clicking on the "Save" button in the
     * configuration dialog.  This will not be called for auto-save operations
     * which can be enabled per (@see Property}.
     */
    public attribute onSave:function();
    
    /**
     * If set, this provise a cancel handler that will be called when the user
     * explicitly cancels the configuration dialog by clicking on the "Cancel"
     * button.
     */
    public attribute onCancel:function();
}
