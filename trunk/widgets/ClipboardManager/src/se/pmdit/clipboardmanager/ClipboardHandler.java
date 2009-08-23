/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package se.pmdit.clipboardmanager;

import java.awt.Toolkit;
import java.awt.datatransfer.Clipboard;
import java.awt.datatransfer.ClipboardOwner;
import java.awt.datatransfer.DataFlavor;
import java.awt.datatransfer.FlavorEvent;
import java.awt.datatransfer.FlavorListener;
import java.awt.datatransfer.StringSelection;
import java.awt.datatransfer.Transferable;
import java.awt.datatransfer.UnsupportedFlavorException;
import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 *
 * @author pmd
 */
public class ClipboardHandler implements FlavorListener, ClipboardOwner {

    private static ClipboardHandler instance = null;
    private Clipboard clipboard;
    private String currentValue = null;
    private String currentMimeType = "";
    private boolean mimeTypeUpdated = false;
    private boolean retryLater = false;

    public ClipboardHandler() {
        updateClipboard();
        clipboard.addFlavorListener(this);
        this.updateMimeType();
    }

    public boolean isUpdated() {
        boolean changed = false;
        String newValue = null;
        Transferable contents = clipboard.getContents(null);

        if (contents.isDataFlavorSupported(DataFlavor.stringFlavor)) {
            try {
                newValue = (String) contents.getTransferData(DataFlavor.stringFlavor);
            } catch (UnsupportedFlavorException ex) {
                Logger.getLogger(ClipboardHandler.class.getName()).log(Level.SEVERE, null, ex);
            } catch (IOException ex) {
                Logger.getLogger(ClipboardHandler.class.getName()).log(Level.SEVERE, null, ex);
            }
        }

        if (getCurrentValue() != null) {
            changed = !currentValue.equals(newValue);
        } else if (newValue != null) {
            changed = true;
        }

        currentValue = newValue;
        return changed;
    }

    private void updateClipboard() {
        if (clipboard != null) {
            clipboard = null;
            System.gc();
        }
        clipboard = Toolkit.getDefaultToolkit().getSystemClipboard();
    }

    private void updateMimeType() {
        try {
            Transferable content = clipboard.getContents(null);
            if (content == null || content.getTransferDataFlavors().length == 0) {
                this.currentMimeType = "";
            } else {
                DataFlavor[] flavours = content.getTransferDataFlavors();
                this.currentMimeType = flavours[flavours.length - 1].getHumanPresentableName();
            }
        } catch (IllegalStateException e) {
            this.retryLater = true;
            System.out.println("Error, try later: " + e.getMessage() + ", clipboard: " + clipboard);
            //updateClipboard();
            //System.out.println("after update clipboard: " + clipboard);
        }

        this.mimeTypeUpdated = true;

//        DataFlavor d[] = content.getTransferDataFlavors();
//        for (int i = 0; i < d.length; i++) {
//            DataFlavor dataFlavor = d[i];
//            System.out.println("df primary type: " + dataFlavor.getPrimaryType() + ", df type: " + dataFlavor.getMimeType() + ", human: " + dataFlavor.getHumanPresentableName());
//        }
    }

    public void setContent(String text) {
      StringSelection ss = new StringSelection(text);
      clipboard.setContents(ss, this);
//        try {
//            Transferable content = new Transferable
//            if (content == null || content.getTransferDataFlavors().length == 0) {
//                this.currentMimeType = "";
//            } else {
//                DataFlavor[] flavours = content.getTransferDataFlavors();
//                this.currentMimeType = flavours[flavours.length - 1].getHumanPresentableName();
//            }
//        } catch (IllegalStateException e) {
//            this.retryLater = true;
//            System.out.println("Error, try later: " + e.getMessage() + ", clipboard: " + clipboard);
//            //updateClipboard();
//            //System.out.println("after update clipboard: " + clipboard);
//        }
    }

    public boolean isMimeTypeUpdated() {
        boolean changed = this.mimeTypeUpdated;
        mimeTypeUpdated = false;
        return changed;
    }

    @Override
    public void flavorsChanged(FlavorEvent e) {
        this.updateMimeType();
    }

    @Override
    public void lostOwnership(Clipboard clipboard, Transferable contents) {
        System.out.println("lost clipboard");
    }

    public static ClipboardHandler getInstance() {
        if (instance == null) {
            instance = new ClipboardHandler();
        }
        return instance;
    }

    public String getCurrentMimeType() {
        return currentMimeType;
    }

    /**
     * @return the currentValue
     */
    public String getCurrentValue() {
        return currentValue;
    }

    /**
     * @return the retryLater
     */
    public boolean isRetryLater() {
        boolean changed = this.retryLater;
        retryLater = false;
        return changed;
    }
}
