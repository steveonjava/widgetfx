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
package org.widgetfx.layout;

import java.lang.Math;
import javafx.ext.swing.*;
import javafx.scene.*;
import javafx.scene.layout.*;
import javafx.util.*;

/**
 * @author Stephen Chin
 * @author Keith Combs
 */
public class Grid extends Container, Resizable {
    public var growRows:Integer[];
    
    public var growColumns:Integer[];
    
    var rowMaximum:Number[];
    
    var columnMaximum:Number[];
    
    var rowMinimum:Number[];
    
    var columnMinimum:Number[];
    
    var rowPreferred:Number[];
    
    var columnPreferred:Number[];
    
    override var maximumHeight = bind sum(rowMaximum);
    
    override var maximumWidth = bind sum(columnMaximum);
    
    override var minimumHeight = bind sum(rowMinimum);
    
    override var minimumWidth = bind sum(columnMinimum);
    
    override var preferredHeight = bind sum(rowPreferred);
    
    override var preferredWidth = bind sum(columnPreferred);
    
    function sum(numbers:Number[]):Number {
        var total:Number = 0;
        for (number in numbers) {
            total += number;
        }
        return total;
    }
    
    function createNumberSequence(length:Integer, value:Number):Number[] {
        return for (i in [1..length]) value;
    }
    
    public var rows:Row[];
    
    override var content = bind getContent(rows);
    
    bound function getContent(rows:Row[]) {
        return for (row in rows) {
            for (cell in row.cells) {
                if (cell instanceof Cell) {
                    (cell as Cell).content
                } else {
                    cell as Node
                }
            }
        }
    }
    
    init {
        impl_layout = doGridLayout;
    }
    
    public function requestLayout():Void {
        impl_requestLayout();
    }

    function recalculateSizes() {
        var numRows = sizeof rows;
        var rowSizes = for (row in rows) sizeof row.cells;
        var numColumns = Sequences.max(rowSizes);
        rowMaximum = createNumberSequence(numRows, 0);
        columnMaximum = createNumberSequence(numColumns as Integer, 0);
        rowMinimum = createNumberSequence(numRows, 0);
        columnMinimum = createNumberSequence(numColumns as Integer, 0);
        rowPreferred = createNumberSequence(numRows, 0);
        columnPreferred = createNumberSequence(numColumns as Integer, 0);
        for (row in rows) {
            for (obj in row.cells) {
                var maximumHeight:Number = -1;
                var maximumWidth:Number = -1;
                var minimumHeight:Number = -1;
                var minimumWidth:Number = -1;
                var preferredHeight:Number = -1;
                var preferredWidth:Number = -1;
                var node:Node = if (obj instanceof Cell) {
                    (obj as Cell).content;
                } else {
                    obj as Node;
                }
                if (node instanceof SwingComponent) {
                    // workaround for a defect in SwingComponent where min/max/pref don't get initialized
                    var component = (node as SwingComponent).getJComponent();
                    maximumHeight = component.getMaximumSize().height;
                    maximumWidth = component.getMaximumSize().width;
                    minimumHeight = component.getMinimumSize().height;
                    minimumWidth = component.getMinimumSize().width;
                    preferredHeight = component.getPreferredSize().height;
                    preferredWidth = component.getPreferredSize().width;
                } else if (node instanceof Resizable) {
                    var resizable = node as Resizable;
                    maximumHeight = resizable.maximumHeight;
                    maximumWidth = resizable.maximumWidth;
                    minimumHeight = resizable.minimumHeight;
                    minimumWidth = resizable.minimumWidth;
                    preferredHeight = resizable.preferredHeight;
                    preferredWidth = resizable.preferredWidth;
                } else {
                    maximumHeight = minimumHeight = preferredHeight = node.boundsInLocal.height;
                    maximumWidth = minimumWidth = preferredWidth = node.boundsInLocal.width;
                }
                if (obj instanceof Cell) {
                    var cell = obj as Cell;
                    if (cell.maximumHeight != -1) {
                        maximumHeight = cell.maximumHeight;
                    }
                    if (cell.maximumWidth != -1) {
                        maximumWidth = cell.maximumWidth;
                    }
                    if (cell.minimumHeight != -1) {
                        minimumHeight = cell.minimumHeight;
                    }
                    if (cell.minimumWidth != -1) {
                        minimumWidth = cell.minimumWidth;
                    }
                    if (cell.preferredHeight != -1) {
                        preferredHeight = cell.preferredHeight;
                    }
                    if (cell.preferredWidth != -1) {
                        preferredWidth = cell.preferredWidth;
                    }
                }
                rowMaximum[indexof row] = Math.max(rowMaximum[indexof row], maximumHeight);
                columnMaximum[indexof obj] = Math.max(columnMaximum[indexof obj], maximumWidth);
                rowMinimum[indexof row] = Math.max(rowMinimum[indexof row], minimumHeight);
                columnMinimum[indexof obj] = Math.max(columnMinimum[indexof obj], minimumWidth);
                rowPreferred[indexof row] = Math.max(rowPreferred[indexof row], preferredHeight);
                columnPreferred[indexof obj] = Math.max(columnPreferred[indexof obj], preferredWidth);
            }
        }
    }
    
    function doGridLayout(g:Group):Void {
        recalculateSizes();
        var x:Number = 0;
        var y:Number = 0;
        for (row in rows) {
            for (cell in row.cells) {
                var node:Node = if (cell instanceof Cell) {
                    (cell as Cell).content
                } else {
                    cell as Node
                }
                if (node instanceof Resizable) {
                    var resizable = node as Resizable;
                    // todo - look at the alignment property for FILL
                    resizable.width = columnPreferred[indexof cell];
                    resizable.height = rowPreferred[indexof row];
                }
                node.impl_layoutX = x;
                node.impl_layoutY = y;
                x += columnPreferred[indexof cell];
            }
            x = 0;
            y += rowPreferred[indexof row];
        }
    }
}
