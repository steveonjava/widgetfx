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

 * This particular file is subject to the "Classpath" exception as provided
 * in the LICENSE file that accompanied this code.

 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
package org.widgetfx.widget.webfeed;

import org.apache.commons.lang.StringEscapeUtils;
import org.jfxtras.scene.*;
import org.jfxtras.scene.layout.*;
import org.widgetfx.*;
import org.widgetfx.config.*;
import javafx.ext.swing.*;
import javafx.animation.*;
import javafx.async.*;
import javafx.scene.*;
import javafx.scene.control.*;
import javafx.scene.effect.*;
import javafx.scene.effect.light.*;
import javafx.scene.input.*;
import javafx.scene.layout.*;
import javafx.scene.paint.*;
import javafx.scene.shape.*;
import javafx.scene.text.*;
import javafx.scene.transform.*;
import java.awt.Desktop;
import java.lang.*;
import java.net.URI;
import java.net.URL;
import java.util.Date;

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
public class WebFeed extends Widget {
    var feedUrl = "http://news.google.com/news?ned=us&topic=h&output=atom";
    var feed:SyndFeed;
    var entrySequence:SyndEntryImpl[];
    var error:String;

    def border = 6;

    function updateFeed():Void {
        var feedInfoCache = HashMapFeedInfoCache.getInstance();
        var feedFetcher:FeedFetcher = new HttpURLFeedFetcher(feedInfoCache);
        try {
            feed = feedFetcher.retrieveFeed(new URL(feedUrl));
            var entries = feed.getEntries();
            entrySequence = for (entry in entries) entry as SyndEntryImpl;
            error = "";
        } catch (e) {
            entrySequence = [];
            error = "Unable to Load Feed";
        }
    }

    function dateSince(date:Date):String {
        if (date == null) {
            return "";
        }
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

    function launchUri(uri:URI) {
        if (Desktop.isDesktopSupported()) {
            var desktop = Desktop.getDesktop();
            if (desktop.isSupported(Desktop.Action.BROWSE )) {
                desktop.browse(uri);
            }
        }
    }

    var entryWidth = bind width - border * 2;
    var entryHeight = 25; // todo - don't hardcode the height of the entries

    function createEntryDisplay(entry:SyndEntryImpl):Node {
        Group {
            var groupOpacity = 0.0;
            var groupFill = Color.BLACK;
            var since:Text = Text {
                font: Font {size: 9}
                content: dateSince(entry.getPublishedDate())
                fill: Color.CYAN
                textOrigin: TextOrigin.TOP
                textAlignment: TextAlignment.RIGHT
                translateX: bind entryWidth - since.layoutBounds.width
            }
            content: [
                Rectangle {
                    width: bind entryWidth
                    height: entryHeight
                    opacity: bind groupOpacity
                    fill: bind groupFill
                },
                VBox {
                    content: [
                        Text {
                            font: Font {size: 11}
                            fill: Color.WHITE
                            textOrigin: TextOrigin.TOP
                            content: StringEscapeUtils.unescapeHtml(entry.getTitle());
                            //wrappingWidth: bind entryWidth - border * 2
                        },
                        Group {content: [
                            Text {
                                font: Font {size: 9}
                                fill: Color.CYAN
                                textOrigin: TextOrigin.TOP
                                textAlignment: TextAlignment.LEFT
                                content: feed.getTitle()
                                //wrappingWidth: bind entryWidth - 55
                            },
                            since
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
                if (event.button == MouseButton.PRIMARY) {
                    groupFill = Color.SLATEGRAY;
                    launchUri(new URI(entry.getLink()));
                    groupOpacity = 0.6;
                }
            }
        }
    }

    init {
        Timeline {
            repeatCount: Timeline.INDEFINITE
            keyFrames: [
                KeyFrame {time: 0s, action: updateFeed},
                KeyFrame {time: 15m}
            ]
        }.play();
    }

    override var configuration = Configuration {
        properties: [
            StringProperty {
                name: "feedUrl";
                value: bind feedUrl with inverse;
            }
        ]
        scene: Scene {
            var label = SwingLabel {text: "RSS Feed:"};
            var textField = SwingTextField {text: bind feedUrl with inverse, columns: 40};
            content: [
                Grid {
                    rows: Row {cells: [
                        label,
                        textField
                    ]}
                }
            ]
        }
        onSave: function() {
            updateFeed();
        }
    }

    init {
        skin = Skin {
            scene: Group {
                content: bind [
                    CacheSafeGroup {
                        cache: true
                        content: Rectangle {
                            // todo - this is too slow, figure out something else
    //                      effect: Lighting {light: PointLight {x: 10, y: 10, z: 10}}
                            width: bind width, height: bind height
                            fill: Color.BLACK
                            arcHeight: 7, arcWidth: 7
                        }
                    },
                    VBox {
                        visible: bind not error.isEmpty()
                        translateY: bind height / 2
                        var errorText:Text;
                        var feedText:Text;
                        content: [
                            errorText = Text {
                                translateX: bind Math.max(0, (width - errorText.boundsInLocal.width) / 2)
                                content: bind error
                                fill: Color.WHITE
                                wrappingWidth: bind width
                            },
                            feedText = Text {
                                translateX: bind Math.max(0, (width - feedText.boundsInLocal.width) / 2)
                                content: bind feedUrl
                                font: Font {size: 11}
                                fill: Color.LIGHTSTEELBLUE
                                wrappingWidth: bind width
                            }
                        ]
                    }
                    if (entrySequence.size() == 0) then [] else {
                        VBox {
                            translateX: border, translateY: border
                            clip: Rectangle {width: bind entryWidth, height: bind height - border * 2, smooth: false}
                            content: bind for (entry in entrySequence) {
                                createEntryDisplay(entry);
                            }
                        }
                    }
                ]
            }
        }
    }
}