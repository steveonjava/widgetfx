/*
 * WidgetFX - JavaFX Desktop Widget Platform
 * Copyright (c) 2008-2009, WidgetFX Group
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 1. Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 * 3. Neither the name of WidgetFX nor the names of its contributors may be used
 *    to endorse or promote products derived from this software without
 *    specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */
package org.widgetfx.nabaztagwidget;

import java.awt.Color;

/**
 * @author Joshua Marinacci
 */
public class BunnyGenerator {

     public static final int BOTTOM = 0;
     public static final int LEFT = 1;
     public static final int MIDDLE = 2;
     public static final int RIGHT = 3;
     public static final int HIGH = 4;
     public static final int BACKWARD = 1;
     public static final int FORWARD = 0;

     static int time = 0;
     static StringBuffer sb = new StringBuffer();

     public static String generateCommand() throws Exception {

         tempo(2);
         //10,motor,1,0,0,0,20,motor,1,60,0,1,30,motor,1,0,0,0
         ear(LEFT,0,FORWARD);
         ear(RIGHT,0,FORWARD);
         tick();
         tick();
         tick();
         ear(LEFT,90,FORWARD);
         //ear(RIGHT,90,BACKWARD);
         tick();
         tick();
         tick();
         ear(LEFT,0,BACKWARD);
         tick();
         tick();
         tick();
         ear(RIGHT,90,FORWARD);
         tick();
         tick();
         tick();
         ear(RIGHT,0,BACKWARD);
         //ear(RIGHT,0,FORWARD);
         //tick();
         //ear(LEFT,90,BACKWARD);
         //ear(RIGHT,90,FORWARD);



         tick();
         led(BOTTOM,Color.RED);
         ear(LEFT,0,FORWARD);
         ear(RIGHT,0,FORWARD);
         tick();
         ear(LEFT,90,FORWARD);
         ear(RIGHT,90,BACKWARD);
         led(BOTTOM,Color.BLACK);
         tick();
         led(BOTTOM,Color.RED);
         ear(LEFT,0,BACKWARD);
         ear(RIGHT,0,FORWARD);
         tick();
         led(BOTTOM,Color.BLACK);
         ear(LEFT,90,BACKWARD);
         ear(RIGHT,90,FORWARD);
         tick();
         led(BOTTOM,Color.RED);
         led(LEFT,Color.BLUE);
         led(MIDDLE,Color.BLUE);
         led(RIGHT,Color.BLUE);
         tick();
         led(BOTTOM,Color.YELLOW);
         led(LEFT,Color.GREEN);
         led(MIDDLE,Color.GREEN);
         led(RIGHT,Color.GREEN);
         for(int i=0; i<4; i++) {
             tick();
             Color c = Color.BLUE;
             if(i % 2 == 0) c = Color.RED;
             led(LEFT,c);
             led(MIDDLE,c);
             led(RIGHT,c);
         }
         for(int i=0; i<10; i++) {
             tick();
             Color c1 = Color.RED;
             Color c2 = Color.WHITE;
             if(i%2==0) {
                 c1 = Color.WHITE;
                 c2 = Color.RED;
             }
             led(LEFT,c1);
             led(MIDDLE,c1);
             led(RIGHT,c1);
             led(BOTTOM,c2);
             led(HIGH,c2);
             if(i%2==0) {
                 ear(RIGHT,30,BACKWARD);
                 ear(LEFT,0,BACKWARD);
             } else {
                 ear(RIGHT,0,FORWARD);
                 ear(LEFT,30,FORWARD);
             }
         }

         return "chor="+sb.toString();
     }

     public static void led(int led, Color color) {
         sb.append(time+","+"led,"+led+","+color.getRed()
+","+color.getGreen()+","+color.getBlue()+",");
     }

     private static void ear(int e, int angle, int dir) {
         int ear = 0;
         if(e == LEFT) {
             ear = 1;
         } else {
             ear = 0;
         }
         sb.append(time+","+"motor,"+ear+","+angle+",0,"+dir+",");
     }

     private static void tempo(int i) {
         sb.append(i+",");
     }

     private static void tick() {
         time+=1;
     }
}