/*
 * Main.fx
 *
 * Created on 2009-jun-22, 20:20:50
 */

// <editor-fold defaultstate="collapsed" desc="imports...">
package se.pmdit.screenshotfx;

import javafx.scene.Node;
import javafx.animation.Timeline;
import javafx.animation.KeyFrame;
import javafx.scene.control.Label;
import javafx.scene.control.Slider;
import javafx.scene.control.Button;
import javafx.scene.image.Image;
import javafx.scene.image.ImageView;
import javafx.stage.StageStyle;
import java.lang.Exception;
import javafx.scene.Group;
import javafx.scene.shape.Rectangle;
import javafx.scene.paint.Color;
import java.awt.GraphicsDevice;
import javafx.util.Sequences;
import org.jfxtras.scene.layout.Grid;
import org.jfxtras.scene.layout.LayoutConstants.*;
import org.jfxtras.scene.layout.ResizableVBox;
import javafx.scene.paint.LinearGradient;
import javafx.scene.paint.Stop;
import javafx.scene.effect.Lighting;
import se.pmdit.imageeditor.ImageEditor;
// </editor-fold>

// TODO: change package name

/**
 * @author pmd
 */
public mixin class ScreenshotFX {

    public var widgetWidth: Number;
    public var widgetHeight: Number;

    var button: Button;
    var captureControls: Grid = Grid { //MigLayout {
        hgap: 0
        width: bind widgetWidth
//        constraints: "wrap"
//        columns: "[]5mm[grow]"
//        rows: "[][][]"
        rows: row([
            button = Button {
//                layoutInfo: MigNodeLayoutInfo {
//                    constraints: "span 1 3"
//                }
                focusTraversable: false
                disable: bind errorOnCapture
                graphic: ImageView {
                    image: Image {
                        url: "{__DIR__}icons/camera-photo.png"
                    }
                }
                action: function() {
                    try {
                        timerDialog = TimerDialog {
                            style: StageStyle.TRANSPARENT;
                            startValue: bind startValue;
                            endValue: bind endValue;
                            timerValue: bind timerValue;
                            onCancel: function() {
                                timer.stop();
                                timerDialog.close();
                            }
                        }
                        timer.playFromStart();
                    }
                    catch(e: Exception) {
                        timer.stop();
                        timerDialog.close();
                        errorOnCapture = true;

                        e.printStackTrace();    // TODO: What throws this?
                    }
                }
            }
            ResizableVBox {
                spacing: 3
                nodeHPos: LEFT
                content: [
                    Button {
//                        layoutInfo: MigNodeLayoutInfo {
//                            constraints: "growx"
//                        }
                        text: bind activeScreenDesc
                        focusTraversable: false
                        //disable: bind (sizeof screens < 2)
                        graphic: ImageView {
                            image: Image {
                                url: "{__DIR__}icons/monitor_go.png"
                            }
                        }
                        action: nextScreen;
                    }
                    Slider {
//                        layoutInfo: MigNodeLayoutInfo {
//                            constraints: "growx"
//                        }
                        min: 0
                        max: 10
                        value: bind timeSlider with inverse
                        vertical: false
                    }
                    Label {
//                        layoutInfo: MigNodeLayoutInfo {
//                            constraints: "growx"
//                        }
                        text: bind infoText
                    }
                ]
            }
        ])
    };

    var errorOnCapture: Boolean = false;

    var infoText: String = bind if(errorOnCapture) "Capture failed :(" else "{%.1f timeSlider}s delay";
    var timerDialog: TimerDialog;

    var startValue: Number = 5;
    var endValue: Number = 0;
    var time: Duration = bind Duration.valueOf((timeSlider * 1000) + 1);
    var timerValue: Number;
    var timer: Timeline = Timeline {
        keyFrames: [
            KeyFrame { time: 0s values: timerValue => startValue },
            KeyFrame {
                time: bind time;
                values: timerValue => 0;
                action: function() {
                    timer.stop();
                    timerDialog.close();
                    
                    try {
                        FX.deferAction(function(): Void {
                            capture();
                        } );
                    }
                    catch(e: Exception) {
                        timerDialog.close();
                        e.printStackTrace();    // TODO: error caught here?
                    }
                }
            }
        ]
    };
    var timeSlider: Number;

    public var mainContent: Node[] = [
        Group {
            content: [
                Rectangle {
                    width: bind widgetWidth
                    height: bind widgetHeight
                    arcWidth: 15
                    arcHeight: 15
                    fill: LinearGradient {
                        startX: 0.5,
                        startY: 0.0,
                        endX: 0.5,
                        endY: widgetHeight
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
                captureControls
            ]
        }
    ];

    var screens: GraphicsDevice[];
    var activeScreen: GraphicsDevice = screens[0];
    var activeScreenDesc: String = bind "{activeScreen.getIDstring()} {activeScreen.getDisplayMode().getWidth()}x{activeScreen.getDisplayMode().getHeight()}";

    init {
        updateScreens();
    }

    function nextScreen(): Void {
        var i = Sequences.indexOf(screens, activeScreen);
        if(++i >= sizeof screens) {
            i = 0;
        }
        activeScreen = screens[i];
    }

    public function updateScreens(): GraphicsDevice[] {
        screens = ScreenGrabber.listScreens();

        if(activeScreen == null) {
            activeScreen = screens[0];
        }
        else {
            var i = Sequences.indexOf(screens, activeScreen);
            if(i < 0) {
                activeScreen = screens[0];
            }
        }

        return screens;
    }

    function capture() {
        //println("id={activeScreen.getIDstring()}");
        //var bounds = screen.getDisplayMode().getWidth()
        var bf = ScreenGrabber.grab(
            activeScreen,
            0,
            0,
            activeScreen.getDisplayMode().getWidth(),
            activeScreen.getDisplayMode().getHeight()
        );

        ImageEditor {
          // TODO: default path
            bf: bf
        }
    }
}
