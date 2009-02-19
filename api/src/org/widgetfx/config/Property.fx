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

/**
 * Properties are persistent entities that are persisted between program
 * invocations.  There are Property subclasses for all the JavaFX basic types
 * (excluding Duration) as well as Sequences of basic types.
 * <p>
 * By default properties bound to a {@link Configuration} are only persisted when the
 * user clicks "Save" in the dialog.  However, if a Property has "autoSave"
 * enabled it will be persisted any time its state changes, which allows
 * application-driven state to be saved in addition to user state.
 *
 * @author Stephen Chin
 * @author Keith Combs
 */
public abstract class Property {
    /**
     * Name of the property as it will be saved to the configuration file.  This
     * must be given a unique value.
     */
    public-init var name:String;
    
    /**
     * If set to true, the state of this propery will be persisted whenever the
     * value changes.  The default is false so that unnecessary state persistence
     * is not performed.
     */
    public-init var autoSave:Boolean;

    /**
     * Implemented by subclasses to provide conversion of values to a common
     * String representation.
     */
    public abstract function getStringValue():String;
    
    /**
     * Implemented by subclasses to provide conversion of values from a common
     * String representation.
     */
    public abstract function setStringValue(value:String):Void;
    
    protected var onChange:function(changedProperty:Property):Void;
    
    package function fireOnChange() {
        if (onChange != null) {
            onChange(this);
        }
    }
}
