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
