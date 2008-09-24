/*
 *  BindToFunctionApplet.fx - A compiled JavaFX program that demonstrates
 *                            how to create JavaFX applets.
 *                            It also demonstrates binding to a function.
 *
 *  Developed 2008 by Jim Weaver (development) and Mark Dingman (graphic design)
 *  to serve as a JavaFX Script example.
 *
 *  Updated by Stephen Chin to run as a widget in WidgetFX
 */
package com.javafxpert.bind_to_function;

import javafx.application.*;
import javafx.ext.swing.*;
import javafx.scene.*;
import javafx.scene.geometry.*;
import javafx.scene.paint.*;
import javafx.scene.text.*;
import javafx.scene.transform.*;
import java.lang.Math;
import org.widgetfx.*;
import org.widgetfx.config.*;

class CircleModel {
  attribute diameter:Integer;
  
  bound function getArea():Number {
    Math.PI * Math.pow(diameter / 2, 2);
  }
}

// schin - change the base class from Applet to Widget
Widget {
  var cModel = CircleModel {};
  var componentViewRef:ComponentView;
  var stageRef:Stage;
  // schin - bonus: persist the diameter between invocations
  configuration: Configuration {
    properties: [
      IntegerProperty {
        name: "diameter"
        value: bind cModel.diameter with inverse
        autoSave: true
      }
    ]
  }
  stage: 
    stageRef = Stage {
      // schin - add the stage width and height since we have no applet tag
      width: 500
      height: 500
      var labelFont = Font {
        name: "Sans Serif"
        style: FontStyle.PLAIN
        size: 32
      }
      content: [
        // schin - moved the fill into a rectangle
        Rectangle {
          width: bind stageRef.width
          height: bind stageRef.height
          fill: LinearGradient {
            startX: 0.0
            startY: 0.0
            endX: 0.0
            endY: 1.0
            stops: [
              Stop { 
                offset: 0.0 
                color: Color.rgb(0, 168, 255) 
              },
              Stop { 
                offset: 1.0 
                color: Color.rgb(0, 65, 103) 
              }
            ]
          }
        },
        Circle {
          centerX: 250
          centerY: 250
          radius: bind cModel.diameter / 2
          fill:
            LinearGradient {
              startX: 0.0
              startY: 0.0
              endX: 0.0
              endY: 1.0
              stops: [
                Stop { 
                  offset: 0.0 
                  color: Color.rgb(74, 74, 74) 
                },
                Stop { 
                  offset: 1.0 
                  color: Color.rgb(9, 9, 9) 
                }
              ]
            }
        },
        Text {
          font: labelFont
          x: 30
          y: 70
          fill: Color.BLACK
          content: bind "Diameter: {cModel.diameter}"
        },
        Text {
          font: labelFont
          x: 260
          y: 70
          fill: Color.BLACK
          content: bind "Area: {%3.2f cModel.getArea()}"
        },
        componentViewRef = ComponentView {
          // schin - make sure widget dragging does not interfere with slider operation
          blocksMouse: true
          transform: bind 
            Translate.translate(40, stageRef.height - 30 -
                                   componentViewRef.getHeight())
          component:
            Slider {
              minimum: 0
              maximum: 400
              preferredSize: bind [stageRef.width - 80, 20]
              value: bind cModel.diameter with inverse
            }
        }
      ]
    }
}
