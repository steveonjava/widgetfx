# Introduction #

In order to develop the WidgetFX framework, a number of technologies are needed, many of which are cutting edge.  This document may become outdated very quickly, so please update it if you notice any discrepancies.

# Details #

You need the following technologies to get started developing WidgetFX
  * Java SE Update 10 JRE and JDK (for transparency, shaped windows, and performance)
  * JavaFX SDK with Netbeans 6.1

## Downloading Java SE Update 10 ##

To install the Java SE Update 10, do the following:
  1. Go to the Java SE 10 download page: http://download.java.net/jdk6/
  1. Download and install the **JRE** installer for your platform of choice
  1. Also, download and install the **JDK** installer

Make sure to check back frequently and get the latest build.

## Getting the latest version of the JavaFX SDK ##

To install the JavaFX SDK:
  1. Go to the JavaFX SDK Website: http://java.sun.com/javafx/downloads/
  1. Find the download link for Netbeans IDE 6.1 with JavaFX (recommended)
    * Alternatively, there is a download for the JavaFX plug-in if you dig deep enough
    * If you follow this path, make sure to update your existing Netbeans install to use Java SE Update 10

Make sure to specify Java SE Update 10 as the JDK for Netbeans when you first start it.

## Opening up WidgetFX in Netbeans ##

There are a total of 6 Netbeans projects.  One for the core API, one for the dock container, three others for each of the core widgets, and one for the web application.

The dependencies are organized as follows:

  * Webapp
    * Container
      * Widgets (Clock, SlideShow, WebFeed)
        * Widget API

Open the container and all its dependent projects in NetBeans (there is an option to automatically open dependent projects).  The project dependencies will automatically cause the api and widget projects to get recompiled whenever you build the container.  There is no need to load the webapp project unless you are deploying to the production instance.

To run the application click "Run" with Container as the main project and the Web Start configuration selected.  This should launch the default Web Start application runner and dynamically read in the widgets you built earlier.

If you run into any issues in future builds, try running a clean before reporting any problems.  Due to a defect in Netbeans, this may require a restart to free up file locks.  (also, make sure the WidgetFX app is not running by checking for a tray icon)