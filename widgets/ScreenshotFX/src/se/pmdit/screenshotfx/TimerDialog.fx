/*
 * TimerDialog.fx
 *
 * Created on 2009-jul-03, 23:17:21
 */

package se.pmdit.screenshotfx;

import org.jfxtras.stage.JFXDialog;











import javafx.scene.Group;
import javafx.scene.Scene;
import javafx.scene.control.Button;
import javafx.scene.control.ProgressIndicator;
import javafx.scene.paint.Color;
import javafx.scene.shape.Rectangle;
import java.lang.SecurityException;

import javafx.scene.effect.Lighting;
import javafx.scene.paint.LinearGradient;
import javafx.scene.paint.Stop;



/**
 * @author pmd
 */

public class TimerDialog extends JFXDialog {

    public var startValue: Number = 5;
    public var endValue: Number = 0;
    public var time: Duration = 5s;
    public var timerValue: Number;
    var progress: Number = bind ProgressIndicator.computeProgress( startValue, timerValue );
//    var timer = Timeline {
//        keyFrames: [
//            KeyFrame { time: 0s values:  timerValue => startValue },
//            KeyFrame {
//                time: time;
//                values: timerValue => 0;
//                action: function() {
//                    this.close();
//                }
//            }
//        ]
//    };

    public var onCancel: function();

    var contentGroup: Group;
// TODO: Cancel button and possible error message
    init {
        width = 90;
        height = 90;
        try {
            alwaysOnTop = true;
        }
        catch(e: SecurityException) {
            println("Could not set progress dialog to 'alwaysOnTop'. Message: {e.getMessage()}");
        }
        modal = true;
        scene = Scene {
            fill: Color.TRANSPARENT;
            content: [
                Rectangle {
                    width: bind width
                    height: bind height
                    arcWidth: 10
                    arcHeight: 10
                    fill: LinearGradient {
                        startX: 0.5,
                        startY: 0.0,
                        endX: 0.5,
                        endY: height
                        proportional: false
                        stops: [
                            Stop {
                                offset: 0.0
                                color: Color.web("#CAE4F1");
                            },
                            Stop {
                                offset: 1.0
                                color: Color.web("#00578A");
                            }
                        ]
                    }
                    cache: true
                    effect: Lighting {
                        diffuseConstant: 1.5
                        specularConstant: 1.2
                        specularExponent: 10
                        surfaceScale: 0.3
                    }
                }
                contentGroup = Group {
                    content: [
                        ProgressIndicator {
                            translateX: bind width / 3
                            translateY: bind height / 3
                            scaleX: 2
                            scaleY: 2
                            progress: bind progress;
                        }
                        Button {
                            translateX: 14
                            translateY: bind height / 1.5
                            text: "Cancel"
                            action: onCancel;
                        }
                    ]
                }
            ]
        }

        //timer.play();
    }


}
