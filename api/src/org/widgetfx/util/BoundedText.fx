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

import javafx.scene.text.Text;
import java.awt.font.FontRenderContext;

/**
 * Extension of Text that will truncate the contained text to a fixed
 * width and add ellipses (...) if there is additional content.
 * <p>
 * In order to cleanly intercept changes to the text, use the text attribute instead
 * of the content attribute in the superclass.
 *
 * @author Stephen Chin
 */
public class BoundedText extends Text {
    /**
     * The desired width of the text.  If the text exceeds this width, it will be
     * truncated to fit and ellipses (...) will be added.
     */
    public attribute width on replace {resizeText()};

    /**
     * Use this in place of the content attribute on the Text superclass.
     */
    public attribute text:String on replace {resizeText()};
    
    private attribute frc = bind new FontRenderContext(null, smooth, false) on replace {resizeText()};
    
    private function textWidth(text:String) {
        return font.getAWTFont().getStringBounds(text, frc).getWidth();
    }
    
    private function resizeText() {
        var trimmed = text;
        if (textWidth(trimmed) > width) {
            for (index in reverse [1..text.length()-1]) {
                trimmed = text.substring(0, index) + "...";
                if (textWidth(trimmed) <= width) {
                    break;
                }
            }
        }
        content = trimmed;
    }
}
