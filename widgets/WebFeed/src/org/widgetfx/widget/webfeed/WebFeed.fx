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
package org.widgetfx.widget.webfeed;

import org.widgetfx.*;
import org.widgetfx.config.*;
import org.widgetfx.util.*;
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
var feedUrl = "http://www.animenewsnetwork.com/all/rss.xml";
var feed:SyndFeed;
var entrySequence:SyndEntryImpl[];
var error:String;

var border = 6;
var width = 150;
var height = 200;
var entryWidth = bind width - border * 2;
var entryHeight = 25; // todo don't hardcode the height of the entries

private function updateFeed():Void {
    var feedInfoCache = HashMapFeedInfoCache.getInstance();
    var feedFetcher:FeedFetcher = new HttpURLFeedFetcher(feedInfoCache);
    try {
        feed = feedFetcher.retrieveFeed(new URL(feedUrl));
        var entries = feed.getEntries();
        entrySequence = Sequences.make(SyndEntryImpl.<<class>>, entries);
        error = null;
    } catch (e) {
        entrySequence = null;
        error = "Unable to Load Feed";
    }
}

private function dateSince(date:Date):String {
    var offset:Number = System.currentTimeMillis() - date.getTime();
    var minutes = (offset / 60000).intValue();
    var hours = minutes / 60;
    var days = hours / 24;
    return if (days > 0) {
        "{days} day{if (days > 1) 's' else ''} ago"
    } else if (hours > 0) {
        "{hours} hr{if (hours > 1) 's' else ''} ago";
    } else {
        "{minutes} min{if (minutes > 1) 's' else ''} ago"
    }
}

private function launchUri(uri:URI) {
    if (Desktop.isDesktopSupported()) {
        var desktop = Desktop.getDesktop();
        if (desktop.isSupported(Desktop.Action.BROWSE )) {
            desktop.browse(uri);
        }
    }
}

private function createEntryDisplay(entry:SyndEntryImpl):Node {
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
                    BoundedText {
                        font: Font {size: 11}
                        fill: Color.WHITE
                        textOrigin: TextOrigin.TOP
                        text: entry.getTitle()
                        width: bind entryWidth - border * 2
                    },
                    Group {content: [
                        BoundedText {
                            font: Font {size: 9}
                            fill: Color.CYAN
                            textOrigin: TextOrigin.TOP
                            horizontalAlignment: HorizontalAlignment.LEADING
                            text: feed.getTitle()
                            width: bind entryWidth - 55
                        },
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
            groupOpacity = 0.6;
        }
        onMouseExited: function(event):Void {
            groupFill = Color.BLACK;
            groupOpacity = 0.0;
        }
        onMousePressed: function(event):Void {
            groupFill = Color.DARKGRAY;
            groupOpacity = 0.6;
        }
        onMouseClicked: function(event):Void {
            if (event.getButton() == 1) {
                groupFill = Color.SLATEGRAY;
                launchUri(new URI(entry.getLink()));
                groupOpacity = 0.6;
            }
        }
    }
}

Timeline {
    repeatCount: Timeline.INDEFINITE
    keyFrames: [
        KeyFrame {time: 0s, action: updateFeed},
        KeyFrame {time: 15m}
    ]
}.start();

Widget {
    resizable: true
    configuration: Configuration {
        properties: [
            StringProperty {
                name: "feedUrl";
                value: bind feedUrl with inverse;
            }
        ]

        component: ClusterPanel {
            var label = Label {text: "RSS Feed:"};
            var textField = TextField {text: bind feedUrl with inverse};
            vcluster: ParallelCluster { content: [
                label,
                textField
            ]}
            hcluster: SequentialCluster { content: [
                label,
                textField
            ]}
        }
        onSave: function() {
            updateFeed();
        }
    }
    stage: Stage {
        width: bind width with inverse
        height: bind height with inverse
        content: [
            Group {
                cache: true
                content: Rectangle {
                    // todo - this is too slow, figure out something else
//                    effect: Lighting {light: PointLight {x: 10, y: 10, z: 10}}
                    width: bind width, height: bind height
                    fill: Color.BLACK
                    arcHeight: 7, arcWidth: 7
                }
            },
            VBox {
                visible: bind error != null
                translateY: bind height / 2
                verticalAlignment: VerticalAlignment.CENTER
                content: [
                    Text {
                        translateX: bind width / 2
                        horizontalAlignment: HorizontalAlignment.CENTER
                        content: bind error
                        fill: Color.WHITE
                    },
                    Text {
                        translateX: bind width / 2
                        horizontalAlignment: HorizontalAlignment.CENTER
                        content: bind feedUrl
                        font: Font {size: 11}
                        fill: Color.LIGHTSTEELBLUE
                    }
                ]

            },
            VBox {
                translateX: border, translateY: border
                clip: Rectangle {width: bind entryWidth, height: bind height - border * 2}
                content: bind for (entry in entrySequence) {
                    createEntryDisplay(entry);
                }
            }
        ]
    }
}
