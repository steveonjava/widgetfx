/*
 * ImageEditor.fx
 *
 * Created on 2009-jul-05, 22:20:00
 */

// <editor-fold defaultstate="collapsed" desc="imports...">
package se.pmdit.screenshotfx.imageeditor;

import javafx.stage.Stage;


import java.lang.System;

import javafx.ext.swing.SwingUtils;
import javafx.scene.Node;

import javafx.scene.Group;
import javafx.scene.image.ImageView;

import javafx.scene.image.Image;
import java.awt.image.BufferedImage;


import java.io.File;

import javafx.reflect.FXLocal;


import javafx.scene.Scene;

import javafx.scene.layout.ClipView;

import javafx.scene.control.ScrollBar;

import javafx.scene.control.Button;
import javafx.scene.layout.Flow;
import javafx.scene.layout.Tile;

import java.awt.Graphics2D;
import java.awt.RenderingHints;


import se.pmdit.screenshotfx.control.NodeListView;
import se.pmdit.screenshotfx.control.ColorPicker;
import javafx.scene.control.Slider;

import javafx.scene.paint.Color;
import javafx.scene.shape.Circle;
import javafx.scene.shape.Rectangle;

import javafx.scene.layout.Panel;


import javafx.scene.shape.Path;

import javafx.scene.shape.ShapeSubtract;
import javafx.scene.control.Label;



import com.sun.javafx.geom.Bounds2D;




import java.lang.Exception;
import javax.swing.JFileChooser;
// </editor-fold>

/**
 * @author pmd
 */
public class ImageEditor extends Stage {
    
    public var changedWithoutSave: Boolean = false; // TODO: Save check

    var imageX: Number = 0;
    var imageY: Number = 0;
    var imageWidth: Number = 0;
    var imageHeight: Number = 0;

    var activeLayer: Layer = bind listView.selected.node as Layer on replace {
        updateLayer();
    };
    var layers = Group {
        //layoutX: bind imageX
        //layoutY: bind imageY
    };

    var drawPanel: DrawArea = DrawArea {
        width: bind imageWidth + imageX     // Adding instead of translating since translation would mean having
        height: bind imageHeight + imageY   // to translate the position of the drawing coordinates as well
        drawTarget: bind activeLayer
        disable: bind not activeLayer.visible
        drawColor: bind colorPicker.color
        brushSize: bind brushSize as Integer
    };

    var selectionPanel = SelectionPath {
        width: bind imageWidth + imageX
        height: bind imageHeight + imageY
    };

    var imageToolGroup = Group {
        content: drawPanel
    };

    var path = System.getProperty("user.home");
    public-read var image: Image on replace {
        imageWidth = image.width;
        imageHeight = image.height;
    };
    public var bf: BufferedImage on replace {
        image = SwingUtils.toFXImage(bf);
    };

    var listView: NodeListView = NodeListView {
        width: 200
        height: 250 // TODO: can't change height?
    };

    public function draw(): Void {
        imageToolGroup.content = drawPanel;
    }

    public function selection(): Void {
        imageToolGroup.content = selectionPanel;
        selectionPanel.drawPath();
    }

    public function text() {
        // TODO: implement
    }

    var fileMenuPanel: Node = Flow {
        vgap: 5
        content: [
            Tile {
                hgap: 10
                content: [
                    Button {
                        id: "save"
                        focusTraversable: false
                        graphic: ImageView {
                            image: Image {
                                url: "{__DIR__}icons/document-save.png"
                            }
                        }
                        action: function() {
                            save();
                        }
                    }
                ]
            }
        ]
    };

    var infoMenuPanel: Node = Flow {
        vgap: 5
        content: [
            Tile {
                vertical: true
                vgap: 2
                content: [
                    Label {
                        textFill: Color.WHITE
                        text: bind "Image {imageWidth} x {imageHeight}" // TODO: icon
                    }
                    Label {
                        textFill: Color.WHITE
                        // TODO: icon
                        // TODO: add info methods to selectionPanel
                        text: bind "Selection {selectionPanel.shape.layoutBounds.width as Integer} x {selectionPanel.shape.layoutBounds.height as Integer}"
                    }
//                    Label {
//                        textFill: Color.WHITE
//                        // TODO: icon
//                        // TODO: add info methods to selectionPanel
//                        text: bind "pos.x={if(scrollWidth > 0) 0 else (scene.width - clipViewContent.layoutBounds.width)}, scene.w={scene.width}, cvc.w={clipViewContent.layoutBounds.width}" //bind "Selection {selectionPanel.shape.layoutBounds.width as Integer} x {selectionPanel.shape.layoutBounds.height as Integer}"
//                    }
                ]
            }
        ]
    };

    // TODO: create real ColorPicker control
    var colorPicker = ColorPicker {
//        width: 24
//        height: 16
    };
    var toolsMenuPanel: Node = Flow {
        vgap: 5
        content: [
            Tile {
                hgap: 10
                content: [
                    Button {
                        id: "draw"
                        focusTraversable: false
                        graphic: ImageView {
                            image: Image {
                                url: "{__DIR__}icons/paintbrush.png"
                            }
                        }
                        action: draw;
                    }
                    Button {
                        id: "selection"
                        focusTraversable: false
                        graphic: ImageView {
                            image: Image {
                                url: "{__DIR__}icons/shape_handles.png"
                            }
                        }
                        action: selection;
                    }
//                    Button {
//                        id: "text"
//                        focusTraversable: false
//                        graphic: ImageView {
//                            image: Image {
//                                url: "{__DIR__}icons/text_smallcaps.png"
//                            }
//                        }
//                        action: text;
//                    }
                    colorPicker
                ]
            }
        ]
    };

    var brushSlider: Slider;
    var maxBrushSize = 20;
    var brushSize: Number = 5;
    var drawMenuPanel: Node = Flow {
        hgap: 5
        content: [
            brushSlider = Slider {
                translateX: 5
                width: 35
                min: 1
                max: maxBrushSize
                value: bind brushSize with inverse
                vertical: false
            },
            Panel {
                content: [
                    Rectangle {
                        width: maxBrushSize + 1
                        height: maxBrushSize + 1
                        fill: Color.TRANSPARENT
                    },
                    Circle {
                        centerX: maxBrushSize / 2
                        centerY: maxBrushSize / 2
                        radius: bind ((brushSize as Integer) / 2) + 1
                        fill: bind colorPicker.color
                        strokeWidth: 1
                        stroke: Color.WHITE
                    }
                ]
            }
        ]
    };

    var selectionMenuPanel: Node = Flow {
        hgap: 5
        content: [
            Tile {
                hgap: 10
                content: [
                    Button {
                        id: "fillSelection"
                        focusTraversable: false
                        graphic: ImageView {
                            image: Image {
                                url: "{__DIR__}icons/paintcan.png"
                            }
                        }
                        action: fillSelection;
                    }
                    Button {
                        id: "createHighlightFromSelection"
                        focusTraversable: false
                        graphic: ImageView {
                            image: Image {
                                url: "{__DIR__}icons/shape_move_backwards.png"
                            }
                        }
                        action: createHightlightLayer;
                    }
                    Button {
                        id: "crop"
                        focusTraversable: false
                        graphic: ImageView {
                            image: Image {
                                url: "{__DIR__}icons/cut_red.png"
                            }
                        }
                        action: cropImageFromSelection;
                    }
//                    Button {  // TODO: frame
//                        id: "frameSelection"
//                        focusTraversable: false
//                        graphic: ImageView {
//                            image: Image {
//                                url: "{__DIR__}icons/paintcan.png"
//                            }
//                        }
//                        action: frameSelection;
//                    }
                ]
            }
        ]
    };

    public function fillSelection(): Void {
        var shape: Path = selectionPanel.getCopyAsPath(true);
        shape.fill = colorPicker.color;
        insert shape into activeLayer.content;
        updateLayer();
    }

    public function createHightlightLayer(): Void {
        var sub = ShapeSubtract {
            a: Rectangle {
                layoutX: imageX
                layoutY: imageY
                width: imageWidth   // TODO: needs binding?
                height: imageHeight
            }
            b: selectionPanel.getCopyAsPath(true)
            fill: colorPicker.color
        }

        var layer = addLayer(sub);
        layer.opacity = 0.5;
        updateLayer();
    }

    public function cropImageFromSelection(): Void {
        hScrollValue = 0;
        vScrollValue = 0;
        
        layers.clip = selectionPanel.getCopyAsPath(true);
        drawPanel.clip = selectionPanel.getCopyAsPath(true);
        selectionPanel.clip = selectionPanel.getCopyAsPath(true);

        imageX = layers.boundsInLocal.minX;
        imageY = layers.boundsInLocal.minY;
        imageWidth = selectionPanel.shape.layoutBounds.width;
        imageHeight = selectionPanel.shape.layoutBounds.height;

        selectionPanel.clear();

        updateLayer();
    }

    public function updateLayer(): Void {
        if(activeLayer != null) {
            // Get from layer
            layerOpacity = activeLayer.opacity;

            // Set in layer
            activeLayer.updateThumbnail();
        }
    }

    var layerOpacitySlider: Slider;
    var layerOpacity: Number on replace {
        activeLayer.opacity = layerOpacity;
    };
    var layerMenuPanel: Node = Flow {
        vertical: true
        vgap: 5
        content: [
            layerOpacitySlider = Slider {
                width: 35
                min: 0
                max: 1
                value: bind layerOpacity with inverse
                vertical: false
            }

//            CheckBox {
//                text: "Drop shadow"
//                allowTriState: false
//                selected: false
//                onMouseClicked: function(e: MouseEvent) {
////                    activeLayer.effect = PerspectiveTransform {
////                                    llx: 13.4, lly: 210.0
////                                    lrx: 186.6, lry: 190.0
////                                    ulx: 13.4, uly: -10.0
////                                    urx: 186.6, ury: 10.0
////                            }
//                }
//            }
        ]
    };

    var layerListMenuPanel: Node = Flow {
        vertical: true
        vgap: 5
        content: [
            Tile {
                hgap: 10
                content: [
                    Button {
                        id: "addLayer"
                        focusTraversable: false
                        graphic: ImageView {
                            image: Image {
                                url: "{__DIR__}icons/add.png"
                            }
                        }
                        action: function() {
                            addLayer(null);
                        }
                    }
                    Button {
                        id: "deleteLayer"
                        focusTraversable: false
                        disable: bind (listView.size == 0)
                        graphic: ImageView {
                            image: Image {
                                url: "{__DIR__}icons/delete.png"
                            }
                        }
                        action: function() {
                            listView.removeSelected();
                        }
                    }
                ]
            },
            listView
        ]
    };

    public var infoMenuPanelOpen: Boolean = false;
    var menu: Menu = Menu {
        translateX: 20;
        translateY: 20;
        blocksMouse: true
        menuPanels: [
            MenuPanel {
                title: "File"
                open: false
                content: fileMenuPanel
            },
            MenuPanel {
                title: "Info"
                open: bind infoMenuPanelOpen with inverse
                content: infoMenuPanel
            },
            MenuPanel {
                title: "Tools"
                content: toolsMenuPanel
            },
            MenuPanel {
                title: "Draw"
                content: drawMenuPanel
            },
            MenuPanel {
                title: "Selection"
                content: selectionMenuPanel
            },
            MenuPanel {
                title: "Active Layer"
                content: layerMenuPanel
            },
            MenuPanel {
                title: "Layers"
                content: layerListMenuPanel
            }
        ]
    };

    var scrollWidth: Number = bind if(imageWidth - clipView.width > 0) imageWidth - clipView.width else 0;
    var hScrollValue: Number = 0;
    var horizontalScroll: ScrollBar = ScrollBar {
        translateY: bind  scene.height - horizontalScroll.height
        min: 0
        max: bind scrollWidth
        disable: bind scrollWidth <= 0
        value: bind hScrollValue with inverse
        vertical: false
        width: bind scene.width - verticalScroll.width
        //visible: bind (scrollWidth > 0)   // TODO: fix
    }

    var scrollHeight: Number = bind if(imageHeight - clipView.height > 0) imageHeight - clipView.height else 0;
    var vScrollValue: Number = 0;
    var verticalScroll: ScrollBar = ScrollBar {
        translateX: bind  scene.width - verticalScroll.width
        min: 0
        max: bind scrollHeight
        disable: bind scrollHeight <= 0
        value: bind vScrollValue with inverse
        vertical: true
        height: bind scene.height
        //visible: bind (scrollHeight > 0)   // TODO: fix
    }



    var imageContentLayoutX: Number = bind if(scrollWidth > 0) 0 else ((scene.width - layers.boundsInLocal.width) / 2) - imageX;
    var imageContentLayoutY: Number = bind if(scrollHeight > 0) 0 else ((scene.height - layers.boundsInLocal.height) / 2) - imageY;
    var clipViewContent: Group;
    var clipView: ClipView = ClipView {
        clipX: bind hScrollValue
        clipY: bind vScrollValue
        node: clipViewContent = Group {
            layoutX: bind imageContentLayoutX
            layoutY: bind imageContentLayoutY
            content: [
                layers,
                imageToolGroup
            ]
        }
        pannable: false
        width: bind scene.width - verticalScroll.width
        height: bind scene.height - horizontalScroll.height

    };

    public-init var enableBackground: Boolean = true;

    init {
        scene = Scene {
            width: 800
            height: 600
            content: [
                clipView,
                menu,
                horizontalScroll,
                verticalScroll
            ]
        }

        arrangeNodes();
    }

    postinit {
        addLayer(ImageView { image: image });
        addLayer(null);
        selection();

        if(enableBackground) {
            insert BlueBackground {
                width: bind scene.width
                height: bind scene.height
                visible: bind scene.width > imageWidth or scene.height > imageHeight
                cache: true
            } before scene.content[0];
        }
    }

    function arrangeNodes() {
        clipView.toFront();
        imageToolGroup.toFront();
        menu.toFront();
        horizontalScroll.toFront();
        verticalScroll.toFront();
    }

//    function addLayer(): Layer {
//        addLayer(null);
//    }

    function addLayer(content: Node): Layer {
        var newLayer: Layer = Layer {
            x: bind imageX
            y: bind imageY
            width: bind imageWidth
            height: bind imageHeight
            content: content
            cache: true
            onChangeEnabled: function(show: Boolean) {
                newLayer.visible = show;
            }
            onRemoved: function(node: Node) {
                if(node instanceof Layer) {
                    deleteLayer(node as Layer);
                }
            }
        };

        // TODO: Hmm... reversed compared to listview layer list... perhpas bind the group to a "reverse layers" sequence?
        insert newLayer into layers.content;

        arrangeNodes();
        listView.add(newLayer, true);

        return newLayer;
    }

    function deleteLayer(layer: Layer): Void {
        delete layer from layers.content;
        if(layer.equals(activeLayer)) {
            activeLayer = null;
        }
    }

    function save() {
        // TODO: No save from widget?
        var captured = captureImage(layers, imageX, imageY, imageWidth, imageHeight);
        saveImage(captured, new File(path));
    }    

    // TODO: Other formats?
    function saveImage(img: BufferedImage, defaultFile: java.io.File) {
//        ScreenGrabber.saveImage(img, defaultFile);
        try {
            var file = defaultFile;
            var fc = JFileChooser {};
            fc.setSelectedFile(file);
            if (fc.showSaveDialog(null) == JFileChooser.APPROVE_OPTION) {
                file = fc.getSelectedFile();
                path = file.getPath();
            }

            var savefile;
            if (not file.getName().toLowerCase().endsWith(".png")) {
                savefile = new File(file.getParent(), "{file.getName()}.png");
            } else {
                savefile = file;
            }

            javax.imageio.ImageIO.write(img, "png", savefile);
            changedWithoutSave = false; // TODO: Error control...
        }
        catch(e: Exception) {
            println("fel: {e.getMessage()}");
        }

    }
}

// TODO: Multi pass scale for quality?
// TODO: Scale with imageW & H calc
public function createThumbnail(bi: BufferedImage, thumbWidth: Number, thumbHeight: Number): Image {
    var scaleFactorW: Number;
    var scaleFactorH: Number;
    var w: Number = thumbWidth;
    var h: Number = thumbHeight;

    scaleFactorW = bi.getWidth() / thumbWidth;
    scaleFactorH = bi.getHeight() / thumbHeight;
    
    if(bi.getHeight() / scaleFactorW > thumbHeight) {
        w = bi.getWidth() / scaleFactorH;
        h = bi.getHeight() / scaleFactorH;
    }
    else {
        w = bi.getWidth() / scaleFactorW;
        h = bi.getHeight() / scaleFactorW;
    }

    var scaledImage: BufferedImage = new BufferedImage(w, h, BufferedImage.TYPE_INT_RGB);
    var g2D: Graphics2D  = scaledImage.createGraphics();

    g2D.setRenderingHint(RenderingHints.KEY_INTERPOLATION, RenderingHints.VALUE_INTERPOLATION_BICUBIC);
    g2D.drawImage(bi, 0, 0, w, h, null);
    g2D.dispose();
    g2D = null;

    return javafx.ext.swing.SwingUtils.toFXImage(scaledImage);
}

// TODO: felhantering... width=0 etc
public function captureImage(node: Node, x: Number, y: Number, width: Number, height: Number): BufferedImage {
    // NOTE: The following code uses internal implementation details
    // that will most certainly change in a future JavaFX release, so
    // please do not copy this code.  We will likely add a proper API
    // for saving images in a later release.

    var context = FXLocal.getContext();
    var nodeClass = context.findClass("javafx.scene.Node");
    var getFXNode = nodeClass.getFunction("impl_getPGNode");
    var sgNode = (getFXNode.invoke(context.mirrorOf(node)) as FXLocal.ObjectValue).asObject();
    var g2dClass = (context.findClass("java.awt.Graphics2D") as FXLocal.ClassType).getJavaImplementationClass();
    var boundsClass = (context.findClass("com.sun.javafx.geom.Bounds2D") as FXLocal.ClassType).getJavaImplementationClass();
    var affineClass = (context.findClass("com.sun.javafx.geom.AffineTransform") as FXLocal.ClassType).getJavaImplementationClass();

    // getContentBounds() method have different signature in JavaFX 1.2
    var getBounds = sgNode.getClass().getMethod("getContentBounds", boundsClass, affineClass);
    var bounds: com.sun.javafx.geom.Bounds2D = getBounds.invoke(sgNode,
            new com.sun.javafx.geom.Bounds2D(),
            new com.sun.javafx.geom.AffineTransform()) as com.sun.javafx.geom.Bounds2D;
//bounds.setBounds(100, 100, 200, 200);

    // Same with render() method
    var paintMethod = sgNode.getClass().getMethod("render", g2dClass, boundsClass, affineClass);
    var img = new BufferedImage(width, height, BufferedImage.TYPE_INT_ARGB);
    var g2 = img.createGraphics();

    var transform = new com.sun.javafx.geom.AffineTransform();
    transform.translate(-x, -y);
    
    paintMethod.invoke(sgNode, g2, bounds, transform);
    g2.dispose();

    return img;
}
