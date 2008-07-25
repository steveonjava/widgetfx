/*
 * WidgetFX - JavaFX Desktop Widget Platform
 * Copyright (C) 2008  Stephen Chin
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.

 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.

 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
package org.widgetfx.widget;

import org.widgetfx.*;
import javafx.application.*;
import javafx.ext.swing.*;
import javafx.async.*;
import javafx.scene.*;
import javafx.scene.geometry.*;
import javafx.animation.*;
import javafx.scene.effect.*;
import javafx.scene.effect.light.*;
import javafx.scene.paint.*;
import javafx.scene.transform.*;
import javafx.scene.text.*;
import javafx.scene.layout.*;
import java.lang.*;
import java.net.URL;
import java.util.Date;
import java.net.URI;
import java.awt.Desktop;

import com.sun.syndication.feed.synd.SyndFeed;
import com.sun.syndication.feed.synd.SyndEntryImpl;
import com.sun.syndication.fetcher.FeedFetcher;
import com.sun.syndication.fetcher.FetcherEvent;
import com.sun.syndication.fetcher.FetcherListener;
import com.sun.syndication.fetcher.impl.FeedFetcherCache;
import com.sun.syndication.fetcher.impl.HashMapFeedInfoCache;
import com.sun.syndication.fetcher.impl.HttpURLFeedFetcher;
import com.sun.javafx.runtime.sequence.Sequences;

/**
 * @author Stephen Chin
 */
var feedUrl = "http://www.animesuki.com/rss.php";
var feedInfoCache = HashMapFeedInfoCache.getInstance();
var feedFetcher:FeedFetcher = new HttpURLFeedFetcher(feedInfoCache);
var feed:SyndFeed = feedFetcher.retrieveFeed(new URL(feedUrl));
var entries = feed.getEntries();
var entrySequence:SyndEntryImpl[] = Sequences.make(SyndEntryImpl.<<class>>, entries);

private function dateSince(date:Date):String {
    var offset:Number = System.currentTimeMillis() - date.getTime();
    var minutes = (offset / 60000).intValue();
    var hours = (offset / 3600000).intValue();
    return if (hours <= 0)
        then "{minutes} min{if (minutes > 1) then 's' else ''} ago"
        else "{hours} hr{if (hours > 1) then 's' else ''} ago";
}

private function fitTextToWidth(text:Text, width:Integer):Text {
    if (text.getWidth() > width) {
        text.content = text.content + "...";
        while (text.getWidth() > width) {
            text.content = text.content.substring(0, text.content.length() - 4) + "...";
        }
    }
    return text;
}

private function launchUri(uri:URI) {
    if (Desktop.isDesktopSupported()) {
        var desktop = Desktop.getDesktop();
        if (desktop.isSupported(Desktop.Action.BROWSE )) {
            desktop.browse(uri);
        }
    }
}

var border = 6;
var width = 150;
var height = 200;
var entryWidth = bind width - border * 2;
var entryHeight = 25; // todo don't hardcode the height of the entries

Widget {
    name: "Web Feed"
    resizable: true
    stage: Stage {
        width: bind width with inverse
        height: bind height with inverse
        content: [
            Group {
                cache: true
                content: Rectangle {
                    effect: Lighting {light: PointLight {x: 10, y: 10, z: 10}}
                    width: bind width, height: bind height
                    fill: Color.BLACK
                    arcHeight: 7, arcWidth: 7
                }
            },
            VBox {
                translateX: border, translateY: border
                clip: Rectangle {width: bind entryWidth, height: height - border * 2}
                content: for (entry in entrySequence) {
                    Group {
                        var groupOpacity = 0.0;
                        var groupFill = Color.BLACK;
                        content: [
                            Rectangle {
                                width: bind entryWidth
                                height: entryHeight
                                opacity: bind groupOpacity
                                fill: bind groupFill
                            },
                            VBox {
                                content: [
                                    fitTextToWidth(Text {
                                            font: Font {size: 11}
                                            content: entry.getTitle()
                                            fill: Color.WHITE
                                            textOrigin: TextOrigin.TOP
                                        }, entryWidth - border * 2),
                                    Group {content: [
                                        fitTextToWidth(Text {
                                            font: Font {size: 9}
                                            content: feed.getTitle()
                                            fill: Color.CYAN
                                            textOrigin: TextOrigin.TOP
                                            horizontalAlignment: HorizontalAlignment.LEADING
                                        }, entryWidth - 55),
                                        Text {
                                            font: Font {size: 9}
                                            content: dateSince(entry.getPublishedDate())
                                            fill: Color.CYAN
                                            textOrigin: TextOrigin.TOP
                                            horizontalAlignment: HorizontalAlignment.TRAILING
                                            translateX: bind entryWidth
                                        }
                                    ]}
                                ],
                            }
                        ]
                        onMouseEntered: function(event):Void {
                            groupFill = Color.SLATEGRAY;
                            groupOpacity = .6;
                        }
                        onMouseExited: function(event):Void {
                            groupFill = Color.BLACK;
                            groupOpacity = 0;
                        }
                        onMousePressed: function(event):Void {
                            groupFill = Color.DARKGRAY;
                            groupOpacity = .6;
                        }
                        onMouseClicked: function(event):Void {
                            groupFill = Color.SLATEGRAY;
                            launchUri(new URI(entry.getLink()));
                            groupOpacity = .6;
                        }
                    }
                }
            }
        ]
    }
}
