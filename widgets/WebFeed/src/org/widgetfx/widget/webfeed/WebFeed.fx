/*
 * WidgetFX - JavaFX Desktop Widget Platform
 * Copyright (c) 2008-2009, WidgetFX Group
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 1. Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 * 3. Neither the name of WidgetFX nor the names of its contributors may be used
 *    to endorse or promote products derived from this software without
 *    specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */
package org.widgetfx.widget.webfeed;

import org.apache.commons.lang.StringEscapeUtils;
import org.jfxtras.scene.layout.*;
import org.widgetfx.*;
import org.widgetfx.config.*;
import javafx.ext.swing.*;
import javafx.animation.*;
import javafx.scene.*;
import javafx.scene.input.*;
import javafx.scene.layout.*;
import javafx.scene.paint.*;
import javafx.scene.shape.*;
import javafx.scene.text.*;
import java.awt.Desktop;
import java.lang.*;
import java.net.URI;
import java.net.URL;
import java.util.Date;

import com.sun.syndication.feed.synd.SyndFeed;
import com.sun.syndication.feed.synd.SyndEntryImpl;
import com.sun.syndication.fetcher.FeedFetcher;
import com.sun.syndication.fetcher.impl.HashMapFeedInfoCache;
import com.sun.syndication.fetcher.impl.HttpURLFeedFetcher;

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

    var updater:Timeline;

    init {
        updater = Timeline {
            repeatCount: Timeline.INDEFINITE
            keyFrames: [
                KeyFrame {time: 15m, action: updateFeed}
            ]
        }
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
        onLoad: function() {
            updateFeed();
        }
        onSave: function() {
            updateFeed();
        }
    }

    init {
        clip = Rectangle {
            width: bind width, height: bind height
            arcHeight: 7, arcWidth: 7
        }
        content = [
            Group {
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
            VBox {
                visible: bind entrySequence.size() > 0
                translateX: border, translateY: border
                clip: Rectangle {width: bind entryWidth, height: bind height - border * 2, smooth: false}
                content: bind for (entry in entrySequence) {
                    createEntryDisplay(entry);
                }
            }
        ];
    }
}