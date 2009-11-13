/**
 * RallyServiceServiceLocator.java
 *
 * This file was auto-generated from WSDL
 * by the Apache Axis 1.4 Apr 22, 2006 (06:55:48 PDT) WSDL2Java emitter.
 */

package rallyws.api;

public class RallyServiceServiceLocator extends org.apache.axis.client.Service implements rallyws.api.RallyServiceService {

    public RallyServiceServiceLocator() {
    }


    public RallyServiceServiceLocator(org.apache.axis.EngineConfiguration config) {
        super(config);
    }

    public RallyServiceServiceLocator(java.lang.String wsdlLoc, javax.xml.namespace.QName sName) throws javax.xml.rpc.ServiceException {
        super(wsdlLoc, sName);
    }

    // Use to get a proxy class for RallyService
    private java.lang.String RallyService_address = "https://rally1.rallydev.com:443/slm/webservice/1.09/RallyService";

    public java.lang.String getRallyServiceAddress() {
        return RallyService_address;
    }

    // The WSDD service name defaults to the port name.
    private java.lang.String RallyServiceWSDDServiceName = "RallyService";

    public java.lang.String getRallyServiceWSDDServiceName() {
        return RallyServiceWSDDServiceName;
    }

    public void setRallyServiceWSDDServiceName(java.lang.String name) {
        RallyServiceWSDDServiceName = name;
    }

    public rallyws.api.RallyService_PortType getRallyService() throws javax.xml.rpc.ServiceException {
       java.net.URL endpoint;
        try {
            endpoint = new java.net.URL(RallyService_address);
        }
        catch (java.net.MalformedURLException e) {
            throw new javax.xml.rpc.ServiceException(e);
        }
        return getRallyService(endpoint);
    }

    public rallyws.api.RallyService_PortType getRallyService(java.net.URL portAddress) throws javax.xml.rpc.ServiceException {
        try {
            rallyws.api.RallyServiceSoapBindingStub _stub = new rallyws.api.RallyServiceSoapBindingStub(portAddress, this);
            _stub.setPortName(getRallyServiceWSDDServiceName());
            return _stub;
        }
        catch (org.apache.axis.AxisFault e) {
            return null;
        }
    }

    public void setRallyServiceEndpointAddress(java.lang.String address) {
        RallyService_address = address;
    }

    /**
     * For the given interface, get the stub implementation.
     * If this service has no port for the given interface,
     * then ServiceException is thrown.
     */
    public java.rmi.Remote getPort(Class serviceEndpointInterface) throws javax.xml.rpc.ServiceException {
        try {
            if (rallyws.api.RallyService_PortType.class.isAssignableFrom(serviceEndpointInterface)) {
                rallyws.api.RallyServiceSoapBindingStub _stub = new rallyws.api.RallyServiceSoapBindingStub(new java.net.URL(RallyService_address), this);
                _stub.setPortName(getRallyServiceWSDDServiceName());
                return _stub;
            }
        }
        catch (java.lang.Throwable t) {
            throw new javax.xml.rpc.ServiceException(t);
        }
        throw new javax.xml.rpc.ServiceException("There is no stub implementation for the interface:  " + (serviceEndpointInterface == null ? "null" : serviceEndpointInterface.getName()));
    }

    /**
     * For the given interface, get the stub implementation.
     * If this service has no port for the given interface,
     * then ServiceException is thrown.
     */
    public java.rmi.Remote getPort(javax.xml.namespace.QName portName, Class serviceEndpointInterface) throws javax.xml.rpc.ServiceException {
        if (portName == null) {
            return getPort(serviceEndpointInterface);
        }
        java.lang.String inputPortName = portName.getLocalPart();
        if ("RallyService".equals(inputPortName)) {
            return getRallyService();
        }
        else  {
            java.rmi.Remote _stub = getPort(serviceEndpointInterface);
            ((org.apache.axis.client.Stub) _stub).setPortName(portName);
            return _stub;
        }
    }

    public javax.xml.namespace.QName getServiceName() {
        return new javax.xml.namespace.QName("http://rallydev.com/webservice/v1_09/service", "RallyServiceService");
    }

    private java.util.HashSet ports = null;

    public java.util.Iterator getPorts() {
        if (ports == null) {
            ports = new java.util.HashSet();
            ports.add(new javax.xml.namespace.QName("http://rallydev.com/webservice/v1_09/service", "RallyService"));
        }
        return ports.iterator();
    }

    /**
    * Set the endpoint address for the specified port name.
    */
    public void setEndpointAddress(java.lang.String portName, java.lang.String address) throws javax.xml.rpc.ServiceException {
        
if ("RallyService".equals(portName)) {
            setRallyServiceEndpointAddress(address);
        }
        else 
{ // Unknown Port Name
            throw new javax.xml.rpc.ServiceException(" Cannot set Endpoint Address for Unknown Port" + portName);
        }
    }

    /**
    * Set the endpoint address for the specified port name.
    */
    public void setEndpointAddress(javax.xml.namespace.QName portName, java.lang.String address) throws javax.xml.rpc.ServiceException {
        setEndpointAddress(portName.getLocalPart(), address);
    }

}
