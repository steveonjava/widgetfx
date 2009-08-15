/*
 * Point.fx
 *
 * Created on 2009-jun-27, 00:34:55
 */

package se.pmdit.screenshotfx.imageeditor;

import java.lang.Math;

import javafx.geometry.Point2D;

/**
 * @author pmd
 */

public class Point {
    public var x: Number = 0;
    public var y: Number = 0;
//    public-read var directionX: Double;
//    public-read var directionY: Double;
//    public var directionToX: Number on replace { directionX = calcDirectionTo(directionToX); }
//    public var directionToY: Number on replace { directionY = calcDirectionTo(directionToY); }

    public function distance(point: Point): Number {
        var dx = point.x - x;
        var dy = point.y - y;
        return Math.sqrt( (dx * dx) + (dy * dy) );
    }

    public function moveToCenter(points: Point[]) {
        var p = center(points);
        this.x = p.x;
        this.y = p.y;
    }

    public function add(point: Point): Point {
        this.x += point.x;
        this.y += point.y;
        return this;
    }

    public function subtract(point: Point): Point {
        this.x -= point.x;
        this.y -= point.y;
        return this;
    }

    public function multiply(value: Number): Point {
        this.x *= value;
        this.y *= value;
        return this;
    }

    public function getCopy(): Point {
        return Point { x: x, y: y };
    }

    public function getImmutable(): Point2D {
        return Point2D { x: this.x, y: this.y };
    }

    public function getFurthestAway(points: Point[]): Point {
        var i: Integer = 0;
        var max: Number = 0;

        for(p in points) {
            var dist = Math.abs(distance(p));
            if(dist > max) {
                max = dist;
                i = indexof p;
            }
        }

        return points[i];
    }


//    function calcDirectionTo(dir: Number): Double {
//        var d = dir - x;
//        var r = Math.sqrt(d * d) * Math.signum(d);
//        return r / dir;
//    }

    override public function toString(): String {
        return "Point[x={x}, y={y}]";
    }

//    public function scale(source: Point, target: Point, moveX: Number, moveY: Number, factor: Number) {
//        if(source.compare(target)) {
//            return;
//        }
//
//        var sourceToTarget = source.distance(target);
//        var thisToSource = distance(source);
//        var ratio = if(thisToSource != sourceToTarget) thisToSource / sourceToTarget else 1;
//        if(ratio > 1) ratio = 1;
//        //println("source={source}, target={target}, thisToSource={thisToSource}, sourceToTarget={sourceToTarget}, ratio={ratio}");
//
//        var lX = Math.signum(x - source.x) * moveX * ratio;
//        var lY = Math.signum(y - source.y) * moveY * ratio;
//
//        //var sdX = Math.signum(lX); //source.calcDirectionTo(x);
//        //var sdY = source.calcDirectionTo(y);
//
//        //println("lX={lX}, factor={factor}");
//
//        x += factor * lX;
//        y += factor * lY;
//    }

    public function compare(p: Point) {
        return (p.x == x and p.y == y);
    }

}

public function center(points: Point[]) {
    var p = Point {};

    for(point in points) {
        p.x += point.x;
        p.y += point.y;
    }

    p.x /= sizeof points;
    p.y /= sizeof points;

    return p;
}

public function copy(points: Point[]) {
    var newPoints: Point[];

    for(p in points) {
        insert p.getCopy() into newPoints;
    }

    return newPoints;
}

public function scaleKeepAspect(points: Point[], scaleCenter: Point, start: Point, target: Point) {
    var sourceValue: Number;
    var targetValue: Number;
    var startValue: Number;

    if(Math.abs(target.x) > Math.abs(target.y)) {
        sourceValue = scaleCenter.x;
        targetValue = target.x;
        startValue = start.x;
    }
    else {
        sourceValue = scaleCenter.y;
        targetValue = target.y;
        startValue = start.y;
    }

    scaleKeepAspect(points, scaleCenter, sourceValue, targetValue, startValue);
}

public function scaleKeepAspect(points: Point[], scaleCenter: Point, source: Number, target: Number, start: Number) {
    var newTarget = target;
    var newSource = source;
    var newStart = start;
    //var factor = (target - source) / (start - source);
    var factor: Number = 1;
    for(i in [1..1]) {
        //newTarget *= factor;
        newSource *= factor;
        newStart *= factor;
        factor = (newTarget - newSource) / (newStart - newSource);
        //println("factor={factor}");
    }
    scaleKeepAspect(points, scaleCenter, factor);
}

public function scaleKeepAspect(points: Point[], scaleCenter: Point, factor: Number) {
    var center = Point.center(points);
    var dx: Integer = 0; //scaleCenter.x - center.x as Integer;
    var dy: Integer = 0; //scaleCenter.y - center.y as Integer;

    //println("dx={dx}, dy={dy}");

    for(p in points) {
        p.x = ((p.x - dx) * factor) + dx;
        p.y = ((p.y - dy) * factor) + dy;
        //print("{indexof p}={p}\t");

//        p.x *= factor;
//        p.y *= factor;
//
//        p.x += scaleCenter.x;
//        p.y += scaleCenter.y;
    }
    //println("");
}

public function scaleToPoint(points: Point[], scaleFrom: Point, scaleStart: Point, scaleTo: Point) {
    //println("scaleStart={scaleStart}, scaleTo={scaleTo}");
    def copyOfScaleFrom = scaleFrom.getCopy();
    def copyOfScaleTo = scaleTo.getCopy(); //.subtract(copyOfScaleFrom);
    //def copyOfPoints: Point[] = points;

    for(p in points) {
        p.subtract(copyOfScaleFrom);
    }

    def factorX = copyOfScaleTo.x / scaleStart.x;
    def factorY = copyOfScaleTo.y / scaleStart.y;
    //println("scaleStart={scaleStart}, copyOfScaleTo={copyOfScaleTo}, factorX={factorX}");
    //println("factorX={factorX}");

    for(p in points) {
        p.x *= factorX;
        p.y *= factorY;
    }

    for(p in points) {
        p.add(copyOfScaleFrom);
    }
}
