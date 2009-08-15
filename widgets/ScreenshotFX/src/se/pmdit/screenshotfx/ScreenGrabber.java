/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package se.pmdit.screenshotfx;

import java.awt.AWTException;
import java.awt.GraphicsDevice;
import java.awt.GraphicsEnvironment;
import java.awt.Rectangle;
import java.awt.Robot;
import java.awt.image.BufferedImage;

/**
 *
 * @author pmd
 */
public class ScreenGrabber {

    public static GraphicsDevice[] listScreens() {
        GraphicsEnvironment env = GraphicsEnvironment.getLocalGraphicsEnvironment();
        return env.getScreenDevices();
    }

    public static BufferedImage grab(GraphicsDevice screen, int x, int y, int width, int height) {
        try {
            Robot robot = new Robot(screen);
            BufferedImage bi = robot.createScreenCapture(new Rectangle(x, y, width, height));
            return bi;
        }
        catch (AWTException e) {
            e.printStackTrace();
        }

        return null;
    }

//    public static void saveImage(BufferedImage img, File defaultFile) {
//        String path = "t:\\_test";
//        String ext[] = { "png" };
//        try {
//
//            FileSaveService fss = (FileSaveService)ServiceManager.lookup("javax.jnlp.FileSaveService");
//            //FileOpenService fos = (FileOpenService)ServiceManager.lookup("javax.jnlp.FileOpenService");
//
//
//            //JFileChooser fc = new JFileChooser();
//            //fc.setSelectedFile(file);
//            //if (fc.showSaveDialog(null) == JFileChooser.APPROVE_OPTION) {
//            //    file = fc.getSelectedFile();
//            //    path = file.getPath();
//            //}
//
////            File savefile;
////            if (!file.getName().toLowerCase().endsWith(".png")) {
////                savefile = new File(file.getParent(), "{file.getName()}.png");
////            } else {
////                savefile = file;
////            }
//
//
//            //File file = new File(path);
//            //FileOutputStream fos = new FileOutputStream(file);
//
//            //FileContents newfc = fss.saveFileDialog(null, null,
//            //fc.getInputStream(), "newFileName.txt");
//            // another way to save a file
//            FileContents fc = fss.saveAsFileDialog(path, ext, null);
//            OutputStream os = fc.getOutputStream(true);
//            javax.imageio.ImageIO.write(img, "png", os);
//        }
//        catch (UnavailableServiceException ex) {
//            String msg = ex.getMessage();
//            Logger.getLogger(ScreenGrabber.class.getName()).log(Level.SEVERE, null, ex);
//        }
//        catch(IOException e) {
//            // "java.io.IOException: Could not get shell folder ID list"
//            String msg = e.getMessage();
//            System.out.println("fel: " + msg);
//        }
//
//    }
}
