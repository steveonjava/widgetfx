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

import java.io.File;
import java.lang.RuntimeException;
import javafx.fxunit.FXTestCase;

/**
 * @author Stephen Chin
 * @author Keith Combs
 */
public class ConfigPersisterTest extends FXTestCase {    
    function testNoFileException() {
        try {
            ConfigPersister {
                properties: StringProperty {}
            }.load();
            fail();
        } catch (e:RuntimeException) {
            // no file set, expect exception
        }
    }
    
    function testNoPropertiesException() {
        try {
            ConfigPersister {
                file: File.createTempFile("config", null);
            }.save();
            fail();
        } catch (e:RuntimeException) {
            // no properties set, expect exception
        }
    }
    
    function testLoadMissingFile() {
        var reader = ConfigPersister {
            properties: StringProperty {}
            file: new File("this/file/does/not/exist")
        }
        assertEquals(false, reader.load());
    }
    
    function testSaveAndLoad() {
        var tempFile = File.createTempFile("config", null);
        var writer = ConfigPersister {
            properties: StringProperty {name: "sample", value: "sampleValue"}
            file: tempFile
        }
        writer.save();
        
        var value:String;
        var reader = ConfigPersister {
            properties: StringProperty {name: "sample", value: bind value with inverse}
            file: tempFile
        }
        assertEquals(true, reader.load());
        assertEquals("sampleValue", value);
    }
    
    function testAutosave() {
        var tempFile = File.createTempFile("config", null);
        var stringProp = StringProperty {name: "sample"};
        var writer = ConfigPersister {
            autoSave: true
            properties: stringProp
            file: tempFile
        };
        writer.save();
        stringProp.value = "sampleValue";
        
        var value:String;
        var reader = ConfigPersister {
            properties: StringProperty {name: "sample", value: bind value with inverse}
            file: tempFile
        }
        reader.load();
        assertEquals("sampleValue", value);
    }
    
}
