/*
 * ClipboardItem.fx
 *
 * Created on 2009-aug-23, 01:42:41
 */

package se.pmdit.clipboardmanager;

import javafx.scene.image.Image;

/**
 * @author pmd
 */

public def images: Image[] = [
  Image { url: "{__DIR__}icons/view-refresh.png" },
  Image { url: "{__DIR__}icons/text-x-generic.png" },
  Image { url: "{__DIR__}icons/image-x-generic.png" },
  Image { url: "{__DIR__}icons/application.png" },
  Image { url: "{__DIR__}icons/application_double.png" }
];
public def REFRESH = 0;
public def TEXT = 1;
public def IMAGE = 2;
public def FILE = 3;
public def FILE_LIST = 4;

public class ClipboardItem extends ClipboardItemBridge {

  public-read var type: Integer = TEXT;
  public var value: Object on replace { println("value={value}"); };
  public var mimeType: String on replace {
    println("mimeType={mimeType}");
    if(mimeType.startsWith("text/")) {
      type = TEXT;
    }
    else if(mimeType.startsWith("image/")) {
      type = IMAGE;
    }
    else if(mimeType.endsWith("file-list")) {
      type = FILE_LIST;
    }
    image = images[type];
  };
  public var image: Image = images[REFRESH];
  public var text: String = bind if(type == TEXT) value as String else "<binary>";
  public var stored: Boolean = false;

  override public function getText(): String {
    return text;
  }

  override public function setText(t: String): Void {
    println("t={t}");
    //value = t;
  }



}
