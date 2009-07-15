package org.widgetfx.widget.shape;

import org.widgetfx.Widget;
import javafx.scene.Group;
import javafx.scene.control.Skin;
import javafx.scene.shape.Rectangle;
import javafx.scene.paint.Color;
import javafx.scene.shape.Circle;
import javafx.animation.Timeline;
import javafx.animation.KeyFrame;
import java.lang.Math;

/**
 * @author Stephen Chin
 * @author Keith Combs
 */
def initialSize = 400;
def numBalls = 10;

class BallModel {
    var speed:Number;
    var radius = 10;
    var color = Color.LIGHTBLUE;
    var x:Number;
    var y:Number;
    var dy:Number = speed;
    var dx:Number = speed;

    function move() {
        x += dx;
        y += dy;
        if (x <= 0 or x >= widget.width) {
            dx = -dx;
        }
        if (y <= 0 or y >= widget.height) {
            dy = -dy;
        }
    }
}

Timeline {
    repeatCount: Timeline.INDEFINITE
    keyFrames: KeyFrame {
        time: 20ms
        action: function() {
            for (ball in balls) {
                ball.move();
            }
        }
    }
}.play();



def balls:BallModel[] = for (i in [1..numBalls]) BallModel {
    speed: Math.random() * 5 + 2
    x: Math.random() * initialSize
    y: Math.random() * initialSize
}

def widget:Widget = Widget {
    width: initialSize
    height: initialSize
    clip: Rectangle {
        width: bind widget.width
        height: bind widget.height
    }
    skin: Skin {
        scene: Group {
            content: bind [
                Rectangle {
                    width: bind widget.width
                    height: bind widget.height
                    fill: Color.DARKBLUE
                },
                for (ball in balls) {
                    Circle {
                        translateX: bind ball.x
                        translateY: bind ball.y
                        radius: bind ball.radius
                        fill: bind ball.color
                    }
                }
            ]
        }
    }
}
return widget;