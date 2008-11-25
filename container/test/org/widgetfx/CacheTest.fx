/*
 * CacheTest.fx
 *
 * Created on Jul 19, 2008, 8:10:25 PM
 */

package org.widgetfx;

import javafx.scene.*;
import javafx.animation.*;
import javafx.scene.Scene;
import javafx.scene.paint.Color;
import javafx.scene.shape.Rectangle;
import javafx.stage.Stage;

/**
 * Simple test case to exercise the scenegraph cache.
 * This is not automated, because it depends on visual feedback.
 * - Expected: The rectangle should resize with the window
 * - Actual (before fix): The rectangle doesn't resize during animation
 *
 * @author Stephen Chin
 */
var width = 200;
var width2 = 200;

Timeline {
    repeatCount: Timeline.INDEFINITE
    autoReverse: true
    keyFrames: [
        KeyFrame {time: 1s, values: [
            width => 400 tween Interpolator.EASEBOTH,
            width2 => 400 tween Interpolator.EASEBOTH
        ]}
    ]
}.play();

Stage {
    width: bind width
    visible: true
    scene: Scene {
        content: [
            Group {
                cache: true
                content: Rectangle {width: bind width2, height: 100, fill: Color.BLUE}
                // todo - fix the horizontal alignment
                translateX: bind width / 2
            }
        ]
    }
}