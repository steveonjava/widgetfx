package rallyws;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNull;
import org.junit.Before;
import org.junit.Test;
import rallywidget.ListWidgetItem;
import rallyws.api.Task;
import rallyws.api.HierarchicalRequirement;
import rallyws.api.Iteration;

import javax.xml.rpc.ServiceException;
import java.rmi.RemoteException;
import java.util.List;

public class RallyWSTest {
    private RallyService service;
    private final static String PROJECT_NAME = "Riders on the Storm";

    /*
            These tests are not intended to be run in an automated suite, they depend on data that varies over time
     */

    @Before
    public void setup() throws RemoteException, ServiceException {
        service = new RallyService();
        service.login("keith.combs@inovis.com", "griffith.5");
    }

    @Test
    public void testLogin() throws RemoteException{
        assertEquals("Keith Combs", service.getDisplayName());
    }

    @Test
    public void testRequestsWithoutLogin() throws RemoteException {
        RallyService service = new RallyService();
        assertNull(service.getDisplayName());
        assertEquals(0, service.getTasks(null, null).size());
        assertEquals(0, service.getItems(null).size());
    }

    @Test
    public void testTaskCount() throws RemoteException {
        List tasks = service.getTasks(null, null);
        assertEquals(78, tasks.size());
    }

    @Test
    public void testTaskOwner() throws RemoteException {
        List<Task> tasks = service.getTasks(null, null);
        for (Task task : tasks) {
            assertEquals("keith.combs@inovis.com", task.getOwner());
        }
    }


    @Test
    public void testGetItems() throws RemoteException {
        List<ListWidgetItem> widgetItemList = service.getItems(null);
        List tasks = service.getTasks(null, null);
        assertEquals(78, widgetItemList.size());
        for (int i = 0; i < widgetItemList.size(); i++) {
            ListWidgetItem listWidgetItem = widgetItemList.get(i);
            Task task = (Task) tasks.get(i);
            assertEquals(task.getName(), listWidgetItem.getName());
            assertEquals(RallyService.RALLY_TASK_URL + task.getObjectID(), listWidgetItem.getUri().toString());
        }
    }

    @Test
    public void testStateFilter() throws RemoteException {
        List<ListWidgetItem> widgetItemList = service.getItems("(State != Completed)");
        List tasks = service.getTasks("(State != Completed)", null);
        assertEquals(13, widgetItemList.size());
        for (int i = 0; i < widgetItemList.size(); i++) {
            ListWidgetItem listWidgetItem = widgetItemList.get(i);
            Task task = (Task) tasks.get(i);
            assertEquals(task.getName(), listWidgetItem.getName());
            assertEquals(RallyService.RALLY_TASK_URL + task.getObjectID(), listWidgetItem.getUri().toString());
        }
    }

    @Test
    public void testGetStories() throws RemoteException {
        Iteration iteration = service.getCurrentIteration(PROJECT_NAME);
        List<HierarchicalRequirement> stories = service.getStories("(((Iteration.ObjectID = " + iteration.getObjectID() + ") and (ScheduleState != Accepted)) and (ScheduleState != Completed))");
        assertEquals(8, stories.size());
    }

    @Test
    public void testUpdateTask() throws RemoteException {
        Iteration iteration = service.getCurrentIteration(PROJECT_NAME);
        List tasks = service.getTasks("((State != Completed) and (Iteration.ObjectID = " + iteration.getObjectID() + "))", null);
        Task myTask = (Task) tasks.get(0);
        String initialState = myTask.getState();
        myTask.setState(TaskStateEnum.Completed.toString());
        service.updateRally(myTask);
        // verify results

        // put it back where it was
        //myTask.setState(initialState);
        //service.updateRally(myTask);
    }

    @Test
    public void testRemainingWorkHours() throws RemoteException {
        Double todo = service.getTotalToDo(PROJECT_NAME);
        assertEquals((Double)13.0, todo);
    }

    @Test
    public void testDaysRemaining() throws RemoteException{
        Double hours = service.getRemainingTime(PROJECT_NAME);
        System.out.println("hours = " + hours);
    }

    

}
