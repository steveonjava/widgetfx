/*
 * Main.fx
 *
 * Created on 2009-aug-21, 23:11:37
 */

package se.pmdit.clipboardmanager;

import javafx.stage.Stage;
import javafx.scene.Scene;

/**
 * @author pmd
 */
public class Main extends Stage, ClipboardManager {

    override var widgetWidth = bind scene.width - 2;
    override var widgetHeight = bind scene.height - 2;

    init {
        scene = Scene {
            width: width
            height: height
            content: mainContent;

        };

    }

}

public function run() {
    Main {
        width: 600
        height: 500
    };
}
