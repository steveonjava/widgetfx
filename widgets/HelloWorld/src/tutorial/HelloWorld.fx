package tutorial;

import org.widgetfx.*;
import javafx.application.*;
import javafx.scene.text.*;

Widget {
    stage: Stage {
        // todo - get rid of requirement to set the size
        content: Text {
            x: 10
            y: 20
            content: "Hello World"
        }
    }
}
