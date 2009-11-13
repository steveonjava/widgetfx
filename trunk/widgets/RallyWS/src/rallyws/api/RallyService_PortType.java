/**
 * RallyService_PortType.java
 *
 * This file was auto-generated from WSDL
 * by the Apache Axis 1.4 Apr 22, 2006 (06:55:48 PDT) WSDL2Java emitter.
 */

package rallyws.api;

public interface RallyService_PortType extends java.rmi.Remote {
    public rallyws.api.CreateResult create(rallyws.api.PersistableObject artifact) throws java.rmi.RemoteException;
    public rallyws.api.OperationResult update(rallyws.api.PersistableObject artifact) throws java.rmi.RemoteException;
    public rallyws.api.WSObject read(rallyws.api.PersistableObject reference) throws java.rmi.RemoteException;
    public rallyws.api.WSObject read(rallyws.api.PersistableObject reference, rallyws.api.Workspace workspace) throws java.rmi.RemoteException;
    public rallyws.api.QueryResult query(rallyws.api.Workspace workspace, java.lang.String artifactType, java.lang.String query, java.lang.String order, boolean fetch, long start, long pagesize) throws java.rmi.RemoteException;
    public rallyws.api.QueryResult query(rallyws.api.Workspace workspace, rallyws.api.Project project, boolean projectScopeUp, boolean projectScopeDown, java.lang.String artifactType, java.lang.String query, java.lang.String order, boolean fetch, long start, long pagesize) throws java.rmi.RemoteException;
    public rallyws.api.OperationResult delete(rallyws.api.PersistableObject reference) throws java.rmi.RemoteException;
    public rallyws.api.WSObject getCurrentSubscription() throws java.rmi.RemoteException;
    public rallyws.api.WSObject getCurrentUser() throws java.rmi.RemoteException;
}
