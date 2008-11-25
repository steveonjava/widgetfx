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
package org.widgetfx.stage;

import java.awt.AWTException;
import java.awt.AWTKeyStroke;
import java.awt.BufferCapabilities;
import java.awt.Color;
import java.awt.Component;
import java.awt.Component.BaselineResizeBehavior;
import java.awt.ComponentOrientation;
import java.awt.Container;
import java.awt.Cursor;
import java.awt.Dialog.ModalExclusionType;
import java.awt.Dimension;
import java.awt.Event;
import java.awt.FocusTraversalPolicy;
import java.awt.Font;
import java.awt.FontMetrics;
import java.awt.Graphics;
import java.awt.GraphicsConfiguration;
import java.awt.HeadlessException;
import java.awt.Image;
import java.awt.ImageCapabilities;
import java.awt.Insets;
import java.awt.LayoutManager;
import java.awt.MenuBar;
import java.awt.MenuComponent;
import java.awt.Point;
import java.awt.PopupMenu;
import java.awt.Rectangle;
import java.awt.Toolkit;
import java.awt.Window;
import java.awt.dnd.DropTarget;
import java.awt.event.ComponentListener;
import java.awt.event.ContainerListener;
import java.awt.event.FocusListener;
import java.awt.event.HierarchyBoundsListener;
import java.awt.event.HierarchyListener;
import java.awt.event.InputMethodListener;
import java.awt.event.KeyListener;
import java.awt.event.MouseListener;
import java.awt.event.MouseMotionListener;
import java.awt.event.MouseWheelListener;
import java.awt.event.WindowFocusListener;
import java.awt.event.WindowListener;
import java.awt.event.WindowStateListener;
import java.awt.im.InputContext;
import java.awt.im.InputMethodRequests;
import java.awt.image.BufferStrategy;
import java.awt.image.ColorModel;
import java.awt.image.ImageObserver;
import java.awt.image.ImageProducer;
import java.awt.image.VolatileImage;
import java.awt.peer.ComponentPeer;
import java.beans.PropertyChangeListener;
import java.io.PrintStream;
import java.io.PrintWriter;
import java.util.EventListener;
import java.util.List;
import java.util.Locale;
import java.util.ResourceBundle;
import java.util.Set;
import javax.accessibility.AccessibleContext;
import javax.swing.JDialog;
import javax.swing.JFrame;
import javax.swing.JLayeredPane;
import javax.swing.JMenuBar;
import javax.swing.JRootPane;
import javax.swing.TransferHandler;

/**
 * @author Stephen Chin
 */
public class DialogToFrame extends JFrame {
    private JDialog dialog;
    
    public DialogToFrame(JDialog dialog) {
        this.dialog = dialog;
    }

    @Override
    public Container getContentPane() {
        return dialog.getContentPane();
    }

    @Override
    public int getDefaultCloseOperation() {
        return dialog.getDefaultCloseOperation();
    }

    @Override
    public Component getGlassPane() {
        return dialog.getGlassPane();
    }

    @Override
    public JMenuBar getJMenuBar() {
        return dialog.getJMenuBar();
    }

    @Override
    public JLayeredPane getLayeredPane() {
        return dialog.getLayeredPane();
    }

    @Override
    public JRootPane getRootPane() {
        return dialog.getRootPane();
    }

    @Override
    public TransferHandler getTransferHandler() {
        return dialog.getTransferHandler();
    }

    @Override
    public void setContentPane(Container contentPane) {
        dialog.setContentPane(contentPane);
    }

    @Override
    public void setDefaultCloseOperation(int operation) {
        dialog.setDefaultCloseOperation(operation);
    }

    @Override
    public void setGlassPane(Component glassPane) {
        dialog.setGlassPane(glassPane);
    }

    @Override
    public void setJMenuBar(JMenuBar menubar) {
        dialog.setJMenuBar(menubar);
    }

    @Override
    public void setLayeredPane(JLayeredPane layeredPane) {
        dialog.setLayeredPane(layeredPane);
    }

    @Override
    public void setTransferHandler(TransferHandler newHandler) {
        dialog.setTransferHandler(newHandler);
    }

    @Override
    public void addNotify() {
        dialog.addNotify();
    }

    @Override
    public AccessibleContext getAccessibleContext() {
        return dialog.getAccessibleContext();
    }

    @Override
    public int getCursorType() {
        throw new IllegalStateException("This is not a valid operation for a dialog");
    }

    @Override
    public synchronized int getExtendedState() {
        throw new IllegalStateException("This is not a valid operation for a dialog");
    }

    @Override
    public Image getIconImage() {
        throw new IllegalStateException("This is not a valid operation for a dialog");
    }

    @Override
    public Rectangle getMaximizedBounds() {
        throw new IllegalStateException("This is not a valid operation for a dialog");
    }

    @Override
    public MenuBar getMenuBar() {
        throw new IllegalStateException("This is not a valid operation for a dialog");
    }

    @Override
    public synchronized int getState() {
        throw new IllegalStateException("This is not a valid operation for a dialog");
    }

    @Override
    public String getTitle() {
        return dialog.getTitle();
    }

    @Override
    public boolean isResizable() {
        return dialog.isResizable();
    }

    @Override
    public boolean isUndecorated() {
        return dialog.isUndecorated();
    }

    @Override
    public void remove(MenuComponent m) {
        dialog.remove(m);
    }

    @Override
    public void removeNotify() {
        dialog.removeNotify();
    }

    @Override
    public void setCursor(int cursorType) {
        throw new IllegalStateException("This is not a valid operation for a dialog");
    }

    @Override
    public synchronized void setExtendedState(int state) {
        throw new IllegalStateException("This is not a valid operation for a dialog");
    }

    @Override
    public void setIconImage(Image image) {
        dialog.setIconImage(image);
    }

    @Override
    public synchronized void setMaximizedBounds(Rectangle bounds) {
        throw new IllegalStateException("This is not a valid operation for a dialog");
    }

    @Override
    public void setMenuBar(MenuBar mb) {
        throw new IllegalStateException("This is not a valid operation for a dialog");
    }

    @Override
    public void setResizable(boolean resizable) {
        dialog.setResizable(resizable);
    }

    @Override
    public synchronized void setState(int state) {
        throw new IllegalStateException("This is not a valid operation for a dialog");
    }

    @Override
    public void setTitle(String title) {
        dialog.setTitle(title);
    }

    @Override
    public void setUndecorated(boolean undecorated) {
        dialog.setUndecorated(undecorated);
    }

    @Override
    public void addPropertyChangeListener(PropertyChangeListener listener) {
        dialog.addPropertyChangeListener(listener);
    }

    @Override
    public void addPropertyChangeListener(String propertyName, PropertyChangeListener listener) {
        dialog.addPropertyChangeListener(propertyName, listener);
    }

    @Override
    public synchronized void addWindowFocusListener(WindowFocusListener l) {
        dialog.addWindowFocusListener(l);
    }

    @Override
    public synchronized void addWindowListener(WindowListener l) {
        dialog.addWindowListener(l);
    }

    @Override
    public synchronized void addWindowStateListener(WindowStateListener l) {
        dialog.addWindowStateListener(l);
    }

    @Override
    public void applyResourceBundle(ResourceBundle rb) {
        dialog.applyResourceBundle(rb);
    }

    @Override
    public void applyResourceBundle(String rbName) {
        dialog.applyResourceBundle(rbName);
    }

    @Override
    public void createBufferStrategy(int numBuffers) {
        dialog.createBufferStrategy(numBuffers);
    }

    @Override
    public void createBufferStrategy(int numBuffers, BufferCapabilities caps) throws AWTException {
        dialog.createBufferStrategy(numBuffers, caps);
    }

    @Override
    public void dispose() {
        dialog.dispose();
    }

    @Override
    public BufferStrategy getBufferStrategy() {
        return dialog.getBufferStrategy();
    }

    @Override
    public Component getFocusOwner() {
        return dialog.getFocusOwner();
    }

    @Override
    public Set<AWTKeyStroke> getFocusTraversalKeys(int id) {
        return dialog.getFocusTraversalKeys(id);
    }

    @Override
    public boolean getFocusableWindowState() {
        return dialog.getFocusableWindowState();
    }

    @Override
    public GraphicsConfiguration getGraphicsConfiguration() {
        return dialog.getGraphicsConfiguration();
    }

    @Override
    public List<Image> getIconImages() {
        return dialog.getIconImages();
    }

    @Override
    public InputContext getInputContext() {
        return dialog.getInputContext();
    }

    @Override
    public <T extends EventListener> T[] getListeners(Class<T> listenerType) {
        return dialog.getListeners(listenerType);
    }

    @Override
    public Locale getLocale() {
        return dialog.getLocale();
    }

    @Override
    public ModalExclusionType getModalExclusionType() {
        return dialog.getModalExclusionType();
    }

    @Override
    public Component getMostRecentFocusOwner() {
        return dialog.getMostRecentFocusOwner();
    }

    @Override
    public Window[] getOwnedWindows() {
        return dialog.getOwnedWindows();
    }

    @Override
    public Window getOwner() {
        return dialog == null ? super.getOwner() : dialog.getOwner();
    }

    @Override
    public Toolkit getToolkit() {
        return dialog == null ? super.getToolkit() : dialog.getToolkit();
    }

    @Override
    public synchronized WindowFocusListener[] getWindowFocusListeners() {
        return dialog.getWindowFocusListeners();
    }

    @Override
    public synchronized WindowListener[] getWindowListeners() {
        return dialog.getWindowListeners();
    }

    @Override
    public synchronized WindowStateListener[] getWindowStateListeners() {
        return dialog.getWindowStateListeners();
    }

    @Override
    public void hide() {
        dialog.hide();
    }

    @Override
    public boolean isActive() {
        return dialog.isActive();
    }

    @Override
    public boolean isAlwaysOnTopSupported() {
        return dialog.isAlwaysOnTopSupported();
    }

    @Override
    public boolean isFocused() {
        return dialog.isFocused();
    }

    @Override
    public boolean isLocationByPlatform() {
        return dialog.isLocationByPlatform();
    }

    @Override
    public boolean isShowing() {
        return dialog.isShowing();
    }

    @Override
    public void pack() {
        dialog.pack();
    }

    @Override
    public boolean postEvent(Event e) {
        return dialog.postEvent(e);
    }

    @Override
    public synchronized void removeWindowFocusListener(WindowFocusListener l) {
        dialog.removeWindowFocusListener(l);
    }

    @Override
    public synchronized void removeWindowListener(WindowListener l) {
        dialog.removeWindowListener(l);
    }

    @Override
    public synchronized void removeWindowStateListener(WindowStateListener l) {
        dialog.removeWindowStateListener(l);
    }

    @Override
    public void reshape(int x, int y, int width, int height) {
        dialog.reshape(x, y, width, height);
    }

    @Override
    public void setBounds(int x, int y, int width, int height) {
        dialog.setBounds(x, y, width, height);
    }

    @Override
    public void setBounds(Rectangle r) {
        dialog.setBounds(r);
    }

    @Override
    public void setCursor(Cursor cursor) {
        dialog.setCursor(cursor);
    }

    @Override
    public void setFocusableWindowState(boolean focusableWindowState) {
        dialog.setFocusableWindowState(focusableWindowState);
    }

    @Override
    public synchronized void setIconImages(List<? extends Image> icons) {
        dialog.setIconImages(icons);
    }

    @Override
    public void setLocationByPlatform(boolean locationByPlatform) {
        if (dialog != null) {
            dialog.setLocationByPlatform(locationByPlatform);
        }
    }

    @Override
    public void setLocationRelativeTo(Component c) {
        dialog.setLocationRelativeTo(c);
    }

    @Override
    public void setMinimumSize(Dimension minimumSize) {
        dialog.setMinimumSize(minimumSize);
    }

    @Override
    public void setModalExclusionType(ModalExclusionType exclusionType) {
        dialog.setModalExclusionType(exclusionType);
    }

    @Override
    public void setSize(Dimension d) {
        dialog.setSize(d);
    }

    @Override
    public void setSize(int width, int height) {
        dialog.setSize(width, height);
    }

    @Override
    public void setVisible(boolean b) {
        dialog.setVisible(b);
    }

    @Override
    public void show() {
        dialog.show();
    }

    @Override
    public void toBack() {
        dialog.toBack();
    }

    @Override
    public void toFront() {
        dialog.toFront();
    }

    @Override
    public Component add(Component comp) {
        return dialog.add(comp);
    }

    @Override
    public Component add(String name, Component comp) {
        return dialog.add(name, comp);
    }

    @Override
    public Component add(Component comp, int index) {
        return dialog.add(comp, index);
    }

    @Override
    public void add(Component comp, Object constraints) {
        if (dialog != null) {
            dialog.add(comp, constraints);
        }
    }

    @Override
    public void add(Component comp, Object constraints, int index) {
        dialog.add(comp, constraints, index);
    }

    @Override
    public synchronized void addContainerListener(ContainerListener l) {
        dialog.addContainerListener(l);
    }

    @Override
    public void applyComponentOrientation(ComponentOrientation o) {
        dialog.applyComponentOrientation(o);
    }

    @Override
    public boolean areFocusTraversalKeysSet(int id) {
        return dialog.areFocusTraversalKeysSet(id);
    }

    @Override
    public int countComponents() {
        return dialog.countComponents();
    }

    @Override
    public void deliverEvent(Event e) {
        dialog.deliverEvent(e);
    }

    @Override
    public void doLayout() {
        dialog.doLayout();
    }

    @Override
    public Component findComponentAt(int x, int y) {
        return dialog.findComponentAt(x, y);
    }

    @Override
    public Component findComponentAt(Point p) {
        return dialog.findComponentAt(p);
    }

    @Override
    public float getAlignmentX() {
        return dialog.getAlignmentX();
    }

    @Override
    public float getAlignmentY() {
        return dialog.getAlignmentY();
    }

    @Override
    public Component getComponent(int n) {
        return dialog.getComponent(n);
    }

    @Override
    public Component getComponentAt(int x, int y) {
        return dialog.getComponentAt(x, y);
    }

    @Override
    public Component getComponentAt(Point p) {
        return dialog.getComponentAt(p);
    }

    @Override
    public int getComponentCount() {
        return dialog.getComponentCount();
    }

    @Override
    public int getComponentZOrder(Component comp) {
        return dialog.getComponentZOrder(comp);
    }

    @Override
    public Component[] getComponents() {
        return dialog.getComponents();
    }

    @Override
    public synchronized ContainerListener[] getContainerListeners() {
        return dialog.getContainerListeners();
    }

    @Override
    public FocusTraversalPolicy getFocusTraversalPolicy() {
        return dialog.getFocusTraversalPolicy();
    }

    @Override
    public Insets getInsets() {
        return dialog.getInsets();
    }

    @Override
    public LayoutManager getLayout() {
        return dialog.getLayout();
    }

    @Override
    public Dimension getMaximumSize() {
        return dialog.getMaximumSize();
    }

    @Override
    public Dimension getMinimumSize() {
        return dialog.getMinimumSize();
    }

    @Override
    public Point getMousePosition(boolean allowChildren) throws HeadlessException {
        return dialog.getMousePosition(allowChildren);
    }

    @Override
    public Dimension getPreferredSize() {
        return dialog.getPreferredSize();
    }

    @Override
    public Insets insets() {
        return dialog.insets();
    }

    @Override
    public void invalidate() {
        dialog.invalidate();
    }

    @Override
    public boolean isAncestorOf(Component c) {
        return dialog.isAncestorOf(c);
    }

    @Override
    public boolean isFocusCycleRoot(Container container) {
        return dialog.isFocusCycleRoot(container);
    }

    @Override
    public boolean isFocusTraversalPolicySet() {
        return dialog.isFocusTraversalPolicySet();
    }

    @Override
    public void layout() {
        dialog.layout();
    }

    @Override
    public void list(PrintStream out, int indent) {
        dialog.list(out, indent);
    }

    @Override
    public void list(PrintWriter out, int indent) {
        dialog.list(out, indent);
    }

    @Override
    public Component locate(int x, int y) {
        return dialog.locate(x, y);
    }

    @Override
    public Dimension minimumSize() {
        return dialog.minimumSize();
    }

    @Override
    public void paint(Graphics g) {
        dialog.paint(g);
    }

    @Override
    public void paintComponents(Graphics g) {
        dialog.paintComponents(g);
    }

    @Override
    public Dimension preferredSize() {
        return dialog.preferredSize();
    }

    @Override
    public void print(Graphics g) {
        dialog.print(g);
    }

    @Override
    public void printComponents(Graphics g) {
        dialog.printComponents(g);
    }

    @Override
    public void remove(int index) {
        dialog.remove(index);
    }

    @Override
    public void remove(Component comp) {
        dialog.remove(comp);
    }

    @Override
    public void removeAll() {
        dialog.removeAll();
    }

    @Override
    public synchronized void removeContainerListener(ContainerListener l) {
        dialog.removeContainerListener(l);
    }

    @Override
    public void setComponentZOrder(Component comp, int index) {
        dialog.setComponentZOrder(comp, index);
    }

    @Override
    public void setFocusTraversalKeys(int id, Set<? extends AWTKeyStroke> keystrokes) {
        dialog.setFocusTraversalKeys(id, keystrokes);
    }

    @Override
    public void setFocusTraversalPolicy(FocusTraversalPolicy policy) {
        if (dialog != null) {
            dialog.setFocusTraversalPolicy(policy);
        }
    }

    @Override
    public void setFont(Font f) {
        dialog.setFont(f);
    }

    @Override
    public void setLayout(LayoutManager mgr) {
        if (dialog != null) {
            dialog.setLayout(mgr);
        }
    }

    @Override
    public void transferFocusBackward() {
        dialog.transferFocusBackward();
    }

    @Override
    public void transferFocusDownCycle() {
        dialog.transferFocusDownCycle();
    }

    @Override
    public void update(Graphics g) {
        dialog.update(g);
    }

    @Override
    public void validate() {
        dialog.validate();
    }

    @Override
    public boolean action(Event evt, Object what) {
        return dialog.action(evt, what);
    }

    @Override
    public synchronized void add(PopupMenu popup) {
        dialog.add(popup);
    }

    @Override
    public synchronized void addComponentListener(ComponentListener l) {
        dialog.addComponentListener(l);
    }

    @Override
    public synchronized void addFocusListener(FocusListener l) {
        dialog.addFocusListener(l);
    }

    @Override
    public void addHierarchyBoundsListener(HierarchyBoundsListener l) {
        dialog.addHierarchyBoundsListener(l);
    }

    @Override
    public void addHierarchyListener(HierarchyListener l) {
        dialog.addHierarchyListener(l);
    }

    @Override
    public synchronized void addInputMethodListener(InputMethodListener l) {
        dialog.addInputMethodListener(l);
    }

    @Override
    public synchronized void addKeyListener(KeyListener l) {
        dialog.addKeyListener(l);
    }

    @Override
    public synchronized void addMouseListener(MouseListener l) {
        dialog.addMouseListener(l);
    }

    @Override
    public synchronized void addMouseMotionListener(MouseMotionListener l) {
        dialog.addMouseMotionListener(l);
    }

    @Override
    public synchronized void addMouseWheelListener(MouseWheelListener l) {
        dialog.addMouseWheelListener(l);
    }

    @Override
    public Rectangle bounds() {
        return dialog.bounds();
    }

    @Override
    public int checkImage(Image image, ImageObserver observer) {
        return dialog.checkImage(image, observer);
    }

    @Override
    public int checkImage(Image image, int width, int height, ImageObserver observer) {
        return dialog.checkImage(image, width, height, observer);
    }

    @Override
    public boolean contains(int x, int y) {
        return dialog.contains(x, y);
    }

    @Override
    public boolean contains(Point p) {
        return dialog.contains(p);
    }

    @Override
    public Image createImage(ImageProducer producer) {
        return dialog.createImage(producer);
    }

    @Override
    public Image createImage(int width, int height) {
        return dialog.createImage(width, height);
    }

    @Override
    public VolatileImage createVolatileImage(int width, int height) {
        return dialog.createVolatileImage(width, height);
    }

    @Override
    public VolatileImage createVolatileImage(int width, int height, ImageCapabilities caps) throws AWTException {
        return dialog.createVolatileImage(width, height, caps);
    }

    @Override
    public void disable() {
        dialog.disable();
    }

    @Override
    public void enable() {
        dialog.enable();
    }

    @Override
    public void enable(boolean b) {
        dialog.enable(b);
    }

    @Override
    public void enableInputMethods(boolean enable) {
        dialog.enableInputMethods(enable);
    }

    @Override
    protected void firePropertyChange(String propertyName, int oldValue, int newValue) {
        dialog.firePropertyChange(propertyName, oldValue, newValue);
    }

    @Override
    public void firePropertyChange(String propertyName, byte oldValue, byte newValue) {
        dialog.firePropertyChange(propertyName, oldValue, newValue);
    }

    @Override
    public void firePropertyChange(String propertyName, char oldValue, char newValue) {
        dialog.firePropertyChange(propertyName, oldValue, newValue);
    }

    @Override
    public void firePropertyChange(String propertyName, short oldValue, short newValue) {
        dialog.firePropertyChange(propertyName, oldValue, newValue);
    }

    @Override
    public void firePropertyChange(String propertyName, long oldValue, long newValue) {
        dialog.firePropertyChange(propertyName, oldValue, newValue);
    }

    @Override
    public void firePropertyChange(String propertyName, float oldValue, float newValue) {
        dialog.firePropertyChange(propertyName, oldValue, newValue);
    }

    @Override
    public void firePropertyChange(String propertyName, double oldValue, double newValue) {
        dialog.firePropertyChange(propertyName, oldValue, newValue);
    }

    @Override
    public Color getBackground() {
        return dialog.getBackground();
    }

    @Override
    public int getBaseline(int width, int height) {
        return dialog.getBaseline(width, height);
    }

    @Override
    public BaselineResizeBehavior getBaselineResizeBehavior() {
        return dialog.getBaselineResizeBehavior();
    }

    @Override
    public Rectangle getBounds() {
        return dialog.getBounds();
    }

    @Override
    public Rectangle getBounds(Rectangle rv) {
        return dialog.getBounds(rv);
    }

    @Override
    public ColorModel getColorModel() {
        return dialog.getColorModel();
    }

    @Override
    public synchronized ComponentListener[] getComponentListeners() {
        return dialog.getComponentListeners();
    }

    @Override
    public ComponentOrientation getComponentOrientation() {
        return dialog.getComponentOrientation();
    }

    @Override
    public Cursor getCursor() {
        return dialog.getCursor();
    }

    @Override
    public synchronized DropTarget getDropTarget() {
        return dialog.getDropTarget();
    }

    @Override
    public synchronized FocusListener[] getFocusListeners() {
        return dialog.getFocusListeners();
    }

    @Override
    public boolean getFocusTraversalKeysEnabled() {
        return dialog.getFocusTraversalKeysEnabled();
    }

    @Override
    public Font getFont() {
        return dialog.getFont();
    }

    @Override
    public FontMetrics getFontMetrics(Font font) {
        return dialog.getFontMetrics(font);
    }

    @Override
    public Color getForeground() {
        return dialog.getForeground();
    }

    @Override
    public Graphics getGraphics() {
        return dialog.getGraphics();
    }

    @Override
    public int getHeight() {
        return dialog.getHeight();
    }

    @Override
    public synchronized HierarchyBoundsListener[] getHierarchyBoundsListeners() {
        return dialog.getHierarchyBoundsListeners();
    }

    @Override
    public synchronized HierarchyListener[] getHierarchyListeners() {
        return dialog.getHierarchyListeners();
    }

    @Override
    public boolean getIgnoreRepaint() {
        return dialog.getIgnoreRepaint();
    }

    @Override
    public synchronized InputMethodListener[] getInputMethodListeners() {
        return dialog.getInputMethodListeners();
    }

    @Override
    public InputMethodRequests getInputMethodRequests() {
        return dialog.getInputMethodRequests();
    }

    @Override
    public synchronized KeyListener[] getKeyListeners() {
        return dialog.getKeyListeners();
    }

    @Override
    public Point getLocation() {
        return dialog.getLocation();
    }

    @Override
    public Point getLocation(Point rv) {
        return dialog.getLocation(rv);
    }

    @Override
    public Point getLocationOnScreen() {
        return dialog.getLocationOnScreen();
    }

    @Override
    public synchronized MouseListener[] getMouseListeners() {
        return dialog.getMouseListeners();
    }

    @Override
    public synchronized MouseMotionListener[] getMouseMotionListeners() {
        return dialog.getMouseMotionListeners();
    }

    @Override
    public Point getMousePosition() throws HeadlessException {
        return dialog.getMousePosition();
    }

    @Override
    public synchronized MouseWheelListener[] getMouseWheelListeners() {
        return dialog.getMouseWheelListeners();
    }

    @Override
    public String getName() {
        return dialog.getName();
    }

    @Override
    public Container getParent() {
        return dialog.getParent();
    }

    @Override
    public ComponentPeer getPeer() {
        return dialog.getPeer();
    }

    @Override
    public synchronized PropertyChangeListener[] getPropertyChangeListeners() {
        return dialog.getPropertyChangeListeners();
    }

    @Override
    public synchronized PropertyChangeListener[] getPropertyChangeListeners(String propertyName) {
        return dialog.getPropertyChangeListeners(propertyName);
    }

    @Override
    public Dimension getSize() {
        return dialog.getSize();
    }

    @Override
    public Dimension getSize(Dimension rv) {
        return dialog.getSize(rv);
    }

    @Override
    public int getWidth() {
        return dialog.getWidth();
    }

    @Override
    public int getX() {
        return dialog == null ? super.getX() : dialog.getX();
    }

    @Override
    public int getY() {
        return dialog == null ? super.getY() : dialog.getY();
    }

    @Override
    public boolean gotFocus(Event evt, Object what) {
        return dialog.gotFocus(evt, what);
    }

    @Override
    public boolean handleEvent(Event evt) {
        return dialog.handleEvent(evt);
    }

    @Override
    public boolean hasFocus() {
        return dialog.hasFocus();
    }

    @Override
    public boolean imageUpdate(Image img, int infoflags, int x, int y, int w, int h) {
        return dialog.imageUpdate(img, infoflags, x, y, w, h);
    }

    @Override
    public boolean inside(int x, int y) {
        return dialog.inside(x, y);
    }

    @Override
    public boolean isBackgroundSet() {
        return dialog.isBackgroundSet();
    }

    @Override
    public boolean isCursorSet() {
        return dialog.isCursorSet();
    }

    @Override
    public boolean isDisplayable() {
        return dialog.isDisplayable();
    }

    @Override
    public boolean isDoubleBuffered() {
        return dialog.isDoubleBuffered();
    }

    @Override
    public boolean isEnabled() {
        return dialog.isEnabled();
    }

    @Override
    public boolean isFocusOwner() {
        return dialog.isFocusOwner();
    }

    @Override
    public boolean isFocusTraversable() {
        return dialog.isFocusTraversable();
    }

    @Override
    public boolean isFocusable() {
        return dialog.isFocusable();
    }

    @Override
    public boolean isFontSet() {
        return dialog.isFontSet();
    }

    @Override
    public boolean isForegroundSet() {
        return dialog.isForegroundSet();
    }

    @Override
    public boolean isLightweight() {
        return dialog.isLightweight();
    }

    @Override
    public boolean isMaximumSizeSet() {
        return dialog.isMaximumSizeSet();
    }

    @Override
    public boolean isMinimumSizeSet() {
        return dialog.isMinimumSizeSet();
    }

    @Override
    public boolean isOpaque() {
        return dialog.isOpaque();
    }

    @Override
    public boolean isPreferredSizeSet() {
        return dialog.isPreferredSizeSet();
    }

    @Override
    public boolean isValid() {
        return dialog.isValid();
    }

    @Override
    public boolean isVisible() {
        return dialog.isVisible();
    }

    @Override
    public boolean keyDown(Event evt, int key) {
        return dialog.keyDown(evt, key);
    }

    @Override
    public boolean keyUp(Event evt, int key) {
        return dialog.keyUp(evt, key);
    }

    @Override
    public void list() {
        dialog.list();
    }

    @Override
    public void list(PrintStream out) {
        dialog.list(out);
    }

    @Override
    public void list(PrintWriter out) {
        dialog.list(out);
    }

    @Override
    public Point location() {
        return dialog.location();
    }

    @Override
    public boolean lostFocus(Event evt, Object what) {
        return dialog.lostFocus(evt, what);
    }

    @Override
    public boolean mouseDown(Event evt, int x, int y) {
        return dialog.mouseDown(evt, x, y);
    }

    @Override
    public boolean mouseDrag(Event evt, int x, int y) {
        return dialog.mouseDrag(evt, x, y);
    }

    @Override
    public boolean mouseEnter(Event evt, int x, int y) {
        return dialog.mouseEnter(evt, x, y);
    }

    @Override
    public boolean mouseExit(Event evt, int x, int y) {
        return dialog.mouseExit(evt, x, y);
    }

    @Override
    public boolean mouseMove(Event evt, int x, int y) {
        return dialog.mouseMove(evt, x, y);
    }

    @Override
    public boolean mouseUp(Event evt, int x, int y) {
        return dialog.mouseUp(evt, x, y);
    }

    @Override
    public void move(int x, int y) {
        dialog.move(x, y);
    }

    @Override
    public void nextFocus() {
        dialog.nextFocus();
    }

    @Override
    public void paintAll(Graphics g) {
        dialog.paintAll(g);
    }

    @Override
    public boolean prepareImage(Image image, ImageObserver observer) {
        return dialog.prepareImage(image, observer);
    }

    @Override
    public boolean prepareImage(Image image, int width, int height, ImageObserver observer) {
        return dialog.prepareImage(image, width, height, observer);
    }

    @Override
    public void printAll(Graphics g) {
        dialog.printAll(g);
    }

    @Override
    public synchronized void removeComponentListener(ComponentListener l) {
        dialog.removeComponentListener(l);
    }

    @Override
    public synchronized void removeFocusListener(FocusListener l) {
        dialog.removeFocusListener(l);
    }

    @Override
    public void removeHierarchyBoundsListener(HierarchyBoundsListener l) {
        dialog.removeHierarchyBoundsListener(l);
    }

    @Override
    public void removeHierarchyListener(HierarchyListener l) {
        dialog.removeHierarchyListener(l);
    }

    @Override
    public synchronized void removeInputMethodListener(InputMethodListener l) {
        dialog.removeInputMethodListener(l);
    }

    @Override
    public synchronized void removeKeyListener(KeyListener l) {
        dialog.removeKeyListener(l);
    }

    @Override
    public synchronized void removeMouseListener(MouseListener l) {
        dialog.removeMouseListener(l);
    }

    @Override
    public synchronized void removeMouseMotionListener(MouseMotionListener l) {
        dialog.removeMouseMotionListener(l);
    }

    @Override
    public synchronized void removeMouseWheelListener(MouseWheelListener l) {
        dialog.removeMouseWheelListener(l);
    }

    @Override
    public synchronized void removePropertyChangeListener(PropertyChangeListener listener) {
        dialog.removePropertyChangeListener(listener);
    }

    @Override
    public synchronized void removePropertyChangeListener(String propertyName, PropertyChangeListener listener) {
        dialog.removePropertyChangeListener(propertyName, listener);
    }

    @Override
    public void repaint() {
        dialog.repaint();
    }

    @Override
    public void repaint(long tm) {
        dialog.repaint(tm);
    }

    @Override
    public void repaint(int x, int y, int width, int height) {
        dialog.repaint(x, y, width, height);
    }

    @Override
    public void repaint(long tm, int x, int y, int width, int height) {
        dialog.repaint(tm, x, y, width, height);
    }

    @Override
    public void requestFocus() {
        dialog.requestFocus();
    }

    @Override
    public boolean requestFocusInWindow() {
        return dialog.requestFocusInWindow();
    }

    @Override
    public void resize(int width, int height) {
        dialog.resize(width, height);
    }

    @Override
    public void resize(Dimension d) {
        dialog.resize(d);
    }

    @Override
    public void setBackground(Color c) {
        if (dialog != null) {
            dialog.setBackground(c);
        }
    }

    @Override
    public void setComponentOrientation(ComponentOrientation o) {
        dialog.setComponentOrientation(o);
    }

    @Override
    public synchronized void setDropTarget(DropTarget dt) {
        dialog.setDropTarget(dt);
    }

    @Override
    public void setEnabled(boolean b) {
        dialog.setEnabled(b);
    }

    @Override
    public void setFocusTraversalKeysEnabled(boolean focusTraversalKeysEnabled) {
        dialog.setFocusTraversalKeysEnabled(focusTraversalKeysEnabled);
    }

    @Override
    public void setFocusable(boolean focusable) {
        dialog.setFocusable(focusable);
    }

    @Override
    public void setForeground(Color c) {
        dialog.setForeground(c);
    }

    @Override
    public void setIgnoreRepaint(boolean ignoreRepaint) {
        dialog.setIgnoreRepaint(ignoreRepaint);
    }

    @Override
    public void setLocale(Locale l) {
        if (dialog != null) {
            dialog.setLocale(l);
        }
    }

    @Override
    public void setLocation(int x, int y) {
        if (dialog != null) {
            dialog.setLocation(x, y);
        }
    }

    @Override
    public void setLocation(Point p) {
        if (dialog != null) {
            dialog.setLocation(p);
        }
    }

    @Override
    public void setMaximumSize(Dimension maximumSize) {
        dialog.setMaximumSize(maximumSize);
    }

    @Override
    public void setName(String name) {
        dialog.setName(name);
    }

    @Override
    public void setPreferredSize(Dimension preferredSize) {
        dialog.setPreferredSize(preferredSize);
    }

    @Override
    public void show(boolean b) {
        dialog.show(b);
    }

    @Override
    public Dimension size() {
        return dialog.size();
    }

    @Override
    public String toString() {
        return dialog.toString();
    }

    @Override
    public void transferFocus() {
        dialog.transferFocus();
    }

    @Override
    public void transferFocusUpCycle() {
        dialog.transferFocusUpCycle();
    }

}
