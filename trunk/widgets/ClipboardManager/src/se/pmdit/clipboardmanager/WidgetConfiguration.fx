/*
 * WidgetConfiguration.fx
 *
 * Created on 2009-aug-21, 22:54:25
 */

package se.pmdit.clipboardmanager;

import javafx.ext.swing.SwingLabel;
import javafx.ext.swing.SwingTextField;
import org.widgetfx.config.Configuration;
import org.widgetfx.config.StringProperty;

import javafx.scene.Scene;
import org.jfxtras.scene.layout.LayoutConstants.*;
import org.jfxtras.scene.layout.Grid;
import org.jfxtras.scene.layout.Cell;

/**
 * @author pmd
 */

public class WidgetConfiguration extends Configuration {

  public var defaultPath: String;
  var tempPath: String;

  override var properties = [
    StringProperty {
      name: "defaultPath"
      value: bind defaultPath with inverse
    }
  ];

  override var scene = Scene {
      var pathLabel = SwingLabel {
          text: "?"
      };
      var pathText = SwingTextField {
          text: bind tempPath with inverse
          columns: 50
      };
      content: [
        Grid {
          rows: row([ pathLabel, Cell { content: pathText, hspan: 2 } ])
        }
      ]
  };
        
}
