/*
 * RallyWidget.fx
 *
 * Created on Sep 9, 2008, 8:46:10 PM
 */

package rallywidget;

import java.text.SimpleDateFormat;
import java.lang.Math;
import javafx.animation.KeyFrame;
import javafx.animation.Timeline;
import javafx.lang.Duration;
import javafx.scene.*;
import javafx.scene.control.*;
import javafx.scene.layout.*;
import javafx.scene.paint.*;
import javafx.scene.text.*;
import javafx.scene.transform.*;
import org.jfxtras.scene.control.*;
import org.jfxtras.scene.layout.*;
import org.jfxtras.scene.layout.XGridLayoutInfo.*;
import org.widgetfx.*;
import org.widgetfx.config.*;
import rallywidget.ArrowUI;
import rallywidget.RallyWidgetUI;
import rallywidget.model.RallyTask;
import rallyws.api.Iteration;
import rallyws.api.Task;
import rallyws.RallyService;

/**
 * @author Keith Combs
 * @author Stephen Chin
 */
var username : String;
var password : String;
var projectName : String;
var service = RallyService {};
var displayName:String;
var currentIteration : Iteration;
var currentTaskIndex : Integer = 0;
var currentArrow : ArrowUI;
var iterationEndDate : String;
//var stories : HierarchicalRequirement[];
var remainingWork : Number;
var remainingTime : Number;
var meterIsRunning : Boolean = false;
var autoResume : Boolean = false;
//var selectedStory : HierarchicalRequirement;
var tasks : Task[];
var arrows : ArrowUI[];
var INVISIBLE = Color.rgb(0, 0, 0, 0);
def DEFAULT_TIME_INCREMENT: Duration = 10s;
def IDLE_TIME_THRESHOLD = 60;
var widget:Widget;
var table : XTable;

function initRallyData():Void {
    var currentDate : java.util.Date = java.util.Date{};

    service.login(username, password);
    displayName = service.getDisplayName();
    rallyWidgetUI.statusActive.visible = false;

    if (not projectName.isEmpty()){
        currentIteration = service.getCurrentIteration(projectName);
        iterationEndDate = new SimpleDateFormat("MM/dd").format(service.getCurrentIteration(projectName).getEndDate().getTime());
        refreshStateFromRally();
    }
    var userNameText = rallyWidgetUI.userName as Text;
    userNameText.content = displayName;
    currentTaskIndex = 0;

}

def BORDER = 14;

var rallyWidgetUI:RallyWidgetUI = RallyWidgetUI {};

var width = bind widget.width on replace {
    updateTransform();
}

var height = bind widget.height on replace {
    updateTransform();
}

var timeline = Timeline {
    repeatCount: Timeline.INDEFINITE
    keyFrames: [
        KeyFrame {
            time: 0s
        },
        KeyFrame {
            time: DEFAULT_TIME_INCREMENT,
            action: function() {
                    updateTaskTimes(0.10);
            }
        }
    ]
}

function updateTaskTimes(incrementHours: Number){
    var idleTime = SystemIdleMonitor.getIdleTimeMillisWin32()/1000;
    println("system idle for :{idleTime} seconds");
    if (idleTime > IDLE_TIME_THRESHOLD){
        stopMeter();
    } else if (autoResume and not meterIsRunning){
        startMeter();
    }
    if (meterIsRunning and tasks.size() > 0){
        var currentTask: Task = tasks[table.selectedRow];
        println("update task {currentTask.getName()} times by {incrementHours}.");
        // increment actuals
        if (rallyws.TaskStateEnum.fromState(currentTask.getState()) != rallyws.TaskStateEnum.InProgress){
            currentTask.setState(rallyws.TaskStateEnum.InProgress.toString());
        }
        var currentActual = if (currentTask.getActuals() == null) 0.0 else currentTask.getActuals();
        var newAct = roundToDecimals(currentActual + incrementHours, 1);
        println("current Actual = {currentActual}, new Actual {newAct}");
        currentTask.setActuals(newAct);

        // decrement To Do
        var currentTodo = if (currentTask.getToDo() == null) 0.0 else currentTask.getToDo();
        var newToDo = roundToDecimals(currentTodo - incrementHours, 1);
        println("current Todo = {currentTodo}, new Todo {newToDo}");
        if (currentTodo >= incrementHours){
            currentTask.setToDo(newToDo);
        } else {
            currentTask.setToDo(roundToDecimals(0.0, 1));
        }

        var results = service.updateRally(currentTask);
        refreshStateFromRally();
    }
}

function roundToDecimals(value: Double, decimals: Integer): Double{
    return Math.round(value*Math.pow(10.0, decimals))/Math.pow(10.0, decimals);
}

function refreshStateFromRally(){
    remainingWork = service.getTotalToDo(projectName);
    remainingTime = service.getRemainingTime(projectName);
    //stories = for (item in service.getStories("(((Iteration.ObjectID = {currentIteration.getObjectID()}) and (ScheduleState != Accepted)) and (ScheduleState != Completed))")) item;
    tasks = for (task in service.getTasks("((State != Completed) and (Iteration.ObjectID = {currentIteration.getObjectID()}))", null)) task;
    rallyWidgetUI.todoStatusBad.visible = (remainingWork > remainingTime);
    rallyWidgetUI.todoStatusGood.visible = (remainingWork <= remainingTime);
}

function updateTransform() {
    var scaleX = widget.width / rallyWidgetUI.border.boundsInLocal.width;
    var scaleY = widget.height / rallyWidgetUI.border.boundsInLocal.height;
    rallyWidgetUI.background.transforms = Transform.scale(scaleX, scaleY);
    rallyWidgetUI.border.transforms = Transform.scale(scaleX, scaleY);
    rallyWidgetUI.headerBackground.transforms = Transform.scale(scaleX, 1);
    rallyWidgetUI.userName.translateX = (widget.width - rallyWidgetUI.border.boundsInLocal.width) / 2;
    rallyWidgetUI.rally.translateX = (widget.width - rallyWidgetUI.border.boundsInLocal.width) * 0.98 - 4;
}

function startMeter(){
    meterIsRunning = true;
    rallyWidgetUI.statusActive.visible = meterIsRunning;
    rallyWidgetUI.statusInactive.visible = not meterIsRunning;
}

function stopMeter(){
    meterIsRunning = false;
    rallyWidgetUI.statusActive.visible = meterIsRunning;
    rallyWidgetUI.statusInactive.visible = not meterIsRunning;
}

rallyWidgetUI.statusInactive.onMouseClicked = function(e) {
    autoResume = true;
    startMeter();
    timeline.play();

}

rallyWidgetUI.statusActive.onMouseClicked = function(e) {
    autoResume = false;
    stopMeter();
    timeline.pause();
}

/*
public var activeTaskImageGroup: Node;
	public var activeTaskIndicator: Node;
	public var inactiveTaskIndicator: Node;
*/
currentArrow.inactiveTaskIndicator.onMouseClicked = function(e) {
    currentArrow.activeTaskImageGroup.visible = true;
    // disable all other tasks
    currentArrow.inactiveTaskIndicator.visible = false;
}


widget = Widget {
    width: 240
    height: 320
    launchHref: "RallyWidget.jnlp"
    var title:String = bind
    if (displayName.length() == 0) "Wrong Login in Configuration" else "{displayName}'s Tasks";
    // todo - file a bug, because this is obnoxious!!!
    //    override var resizable = true;
    
    configuration: Configuration {
        properties: [
            StringProperty {
                name: "username"
                value: bind username with inverse
            },
            StringProperty {
                name: "password"
                value: bind password with inverse
            },
            StringProperty {
                name: "project"
                value: bind projectName with inverse
            }

        ]
        scene: Scene {
            content: XGrid {
                var nameLabel = Label {
                    text: "Username:"
                }
                var nameField = TextBox {
                    text: bind username with inverse
                    columns: 30
                }
                var passwordLabel = Label {
                    text: "Password:"
                }
                var passwordField = XPasswordBox {
                    text: bind password with inverse
                    columns: 30
                }
                var projectLabel = Label {
                    text: "Project:"
                }
                var projectField = TextBox {
                    text: bind projectName with inverse
                    columns: 30
                }
                rows: [
                    row([nameLabel, nameField]),
                    row([passwordLabel, passwordField]),
                    row([projectLabel, projectField])
                ]
            }
        }
        onLoad: initRallyData
        onSave: initRallyData
    }

    content: Group {
        content: [
            rallyWidgetUI,
            XVBox {
                translateX: 15
                translateY: 55
                width: bind widget.width - 25
                height: bind widget.height - 90
                content: [
                    XGrid {
                        rows: [
                            row([
                                Text {content: "Iteration"}
                                Text {content: "Ends"}
                                Text {content: "Total To Do"}
                            ]),
                            row([
                                TextBox {
                                    columns: 10
                                    editable: false
                                    selectOnFocus: false
                                    text: bind if (currentIteration.getName() == null) "" else currentIteration.getName()
                                }
                                TextBox {
                                    columns: 5
                                    editable: false
                                    selectOnFocus: false
                                    text: bind iterationEndDate
                                }
                                TextBox {
                                    columns: 5
                                    editable: false
                                    selectOnFocus: false
                                    text: bind "{roundToDecimals(remainingWork, 1)}h"
                                }
                                HBox {content: [rallyWidgetUI.todoStatusBad, rallyWidgetUI.todoStatusGood]}
                            ])
                        ]
                    },
                    table = XTable {
                        rowType: RallyTask {}.getJFXClass();
                        rows: bind for (task in tasks) {
                            RallyTask {
                                name: task.getName()
                                actuals: service.getTaskTimeHours(task.getActuals())
                                todo: service.getTaskTimeHours(task.getToDo())
                                state: rallyws.TaskStateEnum.fromState(task.getState()).getCodeValue()
                            }
                        }
                    }
                ]
            }
        ];
    }
}
