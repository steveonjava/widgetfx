/*
 * Main.fx
 *
 * Created on 2009-jul-05, 04:53:25
 */

package se.pmdit.screenshotfx;

import javafx.stage.Stage;

import javafx.scene.Scene;

/**
 * @author pmd
 */

public class Main extends Stage, ScreenshotFX {

    override var widgetWidth = bind scene.width - 2;
    override var widgetHeight = bind scene.height - 2 on replace {
        println("widgetHeight={widgetHeight}");
    };
    
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
        width: 300
        height: 64
    };
}
