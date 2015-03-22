# Introduction #

Hopefully you can find an answer here. If not please ask in the user or developer group.


# Details #

**My JAR file XYZ.jar is not found by WidgetFX even though I can enter it's url and download the file.**
  * Do you have a version enabled jar file with for example [Java Web Start JnlpDownloadServlet](http://java.sun.com/j2se/1.5.0/docs/guide/javaws/developersguide/downloadservletguide.html)? I.e accessing the jar with ".../XYZ.jar?version-id=1.0". WidgetFX's method of getting your jar file is not version aware yet, therefore you need to supply a default jar that can be downloaded with no version information specified.

**I get an MalformedURLException when WidgetFX tries to open my jnlp file.**
  * There's a bug in the javafxpackager which produces a malformed "update" tag in the jnlp file. When the file is downloaded by WidgetFX this tag is replaced with a correctly terminated tag. If the file has been edited in a way that the string can't be found a MalformedURLException is thrown. Fix or remove the update tag to solve this.