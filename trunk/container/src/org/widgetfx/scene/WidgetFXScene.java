package org.widgetfx.scene;

import com.sun.javafx.runtime.FXObject;
import com.sun.javafx.runtime.InitHelper;
import com.sun.javafx.runtime.NoMainException;
import com.sun.javafx.runtime.TypeInfo;
import com.sun.javafx.runtime.annotation.Public;
import com.sun.javafx.runtime.location.AbstractVariable;
import com.sun.stylesheet.Stylesheet;
import javafx.lang.Builtins;
import javafx.scene.Node$Intf;
import javafx.scene.Scene;
import javafx.geometry.Rectangle2D$Intf;
import com.sun.javafx.runtime.sequence.Sequences;

@Public
public class WidgetFXScene extends Scene
        implements WidgetFXScene$Intf, FXObject {

    public void initialize$() {
        addTriggers$(this);
        if (this.$javafx$scene$Scene$stage.needDefault()) {
            applyDefaults$javafx$scene$Scene$stage(this);
        }
        if (this.$javafx$scene$Scene$x.needDefault()) {
            applyDefaults$javafx$scene$Scene$x(this);
        }
        if (this.$javafx$scene$Scene$y.needDefault()) {
            applyDefaults$javafx$scene$Scene$y(this);
        }
        if (this.$javafx$scene$Scene$width.needDefault()) {
            applyDefaults$javafx$scene$Scene$width(this);
        }
        if (this.$javafx$scene$Scene$height.needDefault()) {
            applyDefaults$javafx$scene$Scene$height(this);
        }
        if (this.$fill.needDefault()) {
            applyDefaults$fill(this);
        }
        if (this.$content.needDefault()) {
            applyDefaults$content(this);
        }
        if (this.$javafx$scene$Scene$initialized$needs_default$) {
            applyDefaults$javafx$scene$Scene$initialized(this);
        }
        if (this.$cursor.needDefault()) {
            applyDefaults$cursor(this);
        }
        if (this.$stylesheets.needDefault()) {
            applyDefaults$stylesheets(this);
        }
        if (this.$javafx$scene$Scene$stylesheetMap$needs_default$) {
            applyDefaults$javafx$scene$Scene$stylesheetMap(this);
        }
        userInit$(this);
        postInit$(this);
        InitHelper.finish(new AbstractVariable[0]);
    }

    public static void addTriggers$(WidgetFXScene$Intf receiver$) {
        Scene.addTriggers$(receiver$);
    }

    public WidgetFXScene() {
        this(false);
        initialize$();
    }

    public WidgetFXScene(boolean dummy) {
        super(dummy);
    }

    public static void userInit$(WidgetFXScene$Intf receiver$) {
        if ((!(Builtins.isInitialized(receiver$.get$javafx$scene$Scene$width()))) || (!(Builtins.isInitialized(receiver$.get$javafx$scene$Scene$height())))) {
            float w = 0.0F;
            float h = 0.0F;

            for (Node$Intf jfx$751node : Sequences.forceNonNull(TypeInfo.getTypeInfo(Node$Intf.class), receiver$.get$content().getAsSequence())) {
                Node$Intf node = jfx$751node;
                Rectangle2D$Intf bounds = null;
                bounds = (node != null) ? (Rectangle2D$Intf) node.get$javafx$scene$Node$boundsInParent().get() : null;
                if (w < ((bounds != null) ? bounds.get$maxX() : 0.0F)) {
                    w = (bounds != null) ? bounds.get$maxX() : 0.0F;
                }
                if (h < ((bounds != null) ? bounds.get$maxY() : 0.0F)) {
                    h = (bounds != null) ? bounds.get$maxY() : 0.0F;
                }
            }

            if (!(Builtins.isInitialized(receiver$.get$javafx$scene$Scene$width()))) {
                receiver$.get$javafx$scene$Scene$width().setAsFloat(w);
            }
            if (!(Builtins.isInitialized(receiver$.get$javafx$scene$Scene$height()))) {
                receiver$.get$javafx$scene$Scene$height().setAsFloat(h);
            }

        }

        if (Sequences.size(receiver$.get$stylesheets().getAsSequenceRaw()) > 0) {
            receiver$.applyStylesheets(receiver$.get$stylesheets().getAsSequence(), 0);
        }
        receiver$.set$javafx$scene$Scene$initialized(true);
    }

    public static void postInit$(WidgetFXScene$Intf receiver$) {
        Scene.postInit$(receiver$);
    }

    public static void main(String[] args) throws Throwable {
        throw new NoMainException("WidgetFXScene");
    }
}