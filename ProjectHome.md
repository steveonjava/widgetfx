![http://widgetfx.googlecode.com/svn/site/images/WidgetFX_Logo_Transparent.png](http://widgetfx.googlecode.com/svn/site/images/WidgetFX_Logo_Transparent.png)

WidgetFX is a desktop widget platform written in the new JavaFX Script language.  It can run widgets written in either JavaFX Script or Java and takes advantage of the latest features in [Java SE 6](http://java.sun.com/javase/downloads/index.jsp).

Please sign up for the [user mailing list](http://groups.google.com/group/widgetfx-users) to hear the latest news!

1.2.4 Release Version:  [![](http://widgetfx.googlecode.com/svn/site/images/WidgetFX-launch-icon.png)](http://widgetfx.org/dock/launch.jnlp)

10/23/09 - 1.2.4 version released to fix Webstart certificate verification issues.

10/20/09 - 1.2.3 is now available.  This releases should fix the Launch on Startup issues on 64bit and non-english versions of Windows.  Also should fix a network reconnect issue that affected a small number of users.

6/29/09 - The 1.2.1 Release is now generally available featuring:
  * JavaFX 1.2 Compatibility.
  * onShow & onHide API hooks.
  * Improved Widget Security Model.
  * Several Performance enhancements.
  * Fixes transparency on Macs provided latest JDK (u13) is used.
  * Other miscellaneous bug fixes.

**Note** that you may need to delete your config files if you were running the beta.

6/18/09 - The 1.2 SDK Beta Release is available in the downloads section.

5/22/09 -  A [Weather Widget](http://infix-systems.com/weatherwidget/) at long last, by Larry Dickson:

**Update: Now working on the WidgetFX 1.2 release!**

> [![](http://www.infix-systems.com/weatherwidget/widget_snapshot1.jpg)](http://widgetfx.org/dock/launch.jnlp?arg=http://www.infix-systems.com/weatherwidget/InfixWeatherWidget.jnlp)

2/24/09 - New [World Smiley Widget](http://tareitas.webs.com/fx/WorldWidget/) created by Enrique Ceja is now available for WidgetFX 1.1.  You know you want to vote, so please give it a try!
> [![](http://tareitas.webs.com/fx/WorldWidget/screenshot.jpg)](http://widgetfx.org/dock/launch.jnlp?arg=http://myfx.freehostia.com/world_widget/WorldWidget.jnlp)

2/21/09 - 1.1.0 Release:
  * JavaFX 1.1 Compatibility
  * **clip** variable on the Widget object now used for improved drawing performance

1/17/09 - 1.0.4 Release: Includes lots of bugfixes, as well as a new [Calendar Tutorial](http://steveonjava.com/2009/01/27/widgetfx-calendar-tutorial/).  Please give it a try!  (make sure to download the [updated SDK](http://code.google.com/p/widgetfx/downloads/list))

1/6/09 - WidgetFX 1.0 Release

This release has been updated to work with JavaFX 1.0, and has many enhancements including:

  * Dock and Widget Skinning Support
  * New Dock Theme (kudos to Mark Dingman)
  * Embedded Flash/Flex Widgets
  * SlideShow Scaling Improvements
  * Performance Enhancements and Many Bugfixes!

10/27/08 - New [World Clock widget](https://worldclock-application.dev.java.net/#widget) created by Ludovic:

**Update: Now working on the WidgetFX 1.2 release!**

> [![](https://worldclock-application.dev.java.net/widget-view.png)](http://widgetfx.org/dock/launch.jnlp?arg=https://worldclock-application.dev.java.net/widget-webstart/launch.jnlp)

10/14/08 - New experimental support for switching themes.  Give it a try:
  * [Inovis Corporate Theme](http://widgetfx.org/dock/launch.jnlp?arg=http://widgetfx.org/themes/inovis/inovis.theme)
  * [WidgetFX Default Theme](http://widgetfx.org/dock/launch.jnlp?arg=http://widgetfx.org/themes/default/widgetfx.theme)

10/8/09 - Pär Dahlberg posted an excellent Widget tutorial on his [blog](http://www.pmdit.se/blog/2008/10/07/javafx_widgetfx_and_my_first_widget.html) which walks you through creating a [DiskSpace Widget](http://widgetfx.org/dock/launch.jnlp?arg=http://pmdit.se/widgets/diskspace/launch.jnlp).  Give it a try:

> [![](http://pmdit.se/widgets/diskspace/widget-diskspace_0.2.jpg)](http://widgetfx.org/dock/launch.jnlp?arg=http://pmdit.se/widgets/diskspace/launch.jnlp)

10/7/09 - The WidgetFX [license](http://widgetfx.googlecode.com/svn/trunk/LICENSE.txt) is even more commercial friendly with the inclusion of the "Classpath" exception popularized by Sun's open-source release of Java.

9/24/08 - Released the 0.1.5 patch which improves performance by over 200%!  For the full details, check out the posting on the mailing lists.

9/18/08 - Calling all Widget developers!  We just finished up the 0.1 release complete with a tutorial and Widget Runner, so give it a try and help us make the API even better.

8/3/08 - Demo updated to support pluggable Widgets using the (+) button in the dock.  Wiki entry with details coming soon...

8/1/08 - Demo updated to take advantage of the JavaFX SDK released today!

### Why Develop Widgets for WidgetFX? ###

The biggest setback for user interface design in the history of modern computing was the marketing push for thin-client, web-based UIs.  The whole software industry has been shackled by browser incompatibilities, Javascript limitations, and a document-centric model for web applications.  It has taken a decade of engineering and framework design in HTML and Javascript to match what desktop client technology could easily do in the 80s.

WidgetFX takes advantage of Sun's JavaFX client technology to create stunning user interfaces in a fraction of the time you would spend with traditional web technologies, while providing simple one-click deployment and powerful desktop integration.  If you can dream of an application or design, WidgetFX makes it easy and enjoyable to develop.

How WidgetFX compares to other widget containers:
  * **Open-Source** - WidgetFX is a 100% open-source widget container (widgets themselves can be licensed commercially)
  * **Cross-platform Support** - There are a plethora of widget frameworks, but they are all incompatible, and none of them are truly cross-platform.  WidgetFX runs on all major platforms including Windows XP/Vista, Linux, and Mac OS X.
  * **Robust Security Model** - The migration of web technologies to widgets has left gaping security holes, which is a problem all Javascript based widget frameworks share.  In contrast, WidgetFX has a robust security model that leverages the secure sandbox of the Java platform. (planned for 0.2 release)
  * **Rich Desktop Applications** - Most widget containers are porting legacy web technologies like HTML, CSS, and Javascript back to the desktop, which doesn't allow them to take advantage of Rich Internet Application (RIA) functionality.  In contrast, WidgetFX is designed to be on the front-end of a Rich Desktop Application (RDA) movement by providing a very rich library of visual, animation, and media capabilities.

How WidgetFX differs from existing Java deployment options (Applets/Web Start):
  * **Low-memory Footprint** - Within a browser applets can share a single VM, but once they are dragged to the desktop to be "web-startified" they lose this capability.  For a large number of widgets, this will quickly add up to a large footprint both in memory and JVM startup time.
  * **Open on Startup** - Widget containers both startup automatically on boot and also start any widgets that were open on close.  While you could add hooks to a web-start application to do this for a single application, it is not as seamless as having the user "expect" your widget to be there on start-up.
  * **Widget Mindshare** - Widgets are becoming mainstream, and while they may be comparable to desktop applications, Java will not be perceived as being a player in this space without having a viable offering.  Perhaps the biggest jab on this one came from the w3c in their Widget Landscape report:
    * "3.2 Differences from Java Applets ... It is argued that the most notable difference between them is that widgets are easier for authors to create than Java applets. ... Applets are intended to run inside Web pages, while widgets as described in this document generally serve the purpose of stand-alone applications that run outside of a Web browser."
    * WidgetFX directly addresses these issues through the JavaFX Script language, which simplifies authoring of widgets, and desktop integration features which set WidgetFX widgets apart from standard Java applets



![http://widgetfx.googlecode.com/svn/site/images/widgetsundocked_ScreenCap.jpg](http://widgetfx.googlecode.com/svn/site/images/widgetsundocked_ScreenCap.jpg)