package com.eastspring.tom.cart.core.utl;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import com.sun.imageio.plugins.common.ImageUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;

public class ImageUtl {

    public enum ImageType {
        JPEG,
        JPG,
        PNG
    }

    private static final Logger LOGGER = LoggerFactory.getLogger(ImageUtil.class);

    public void compareImages(final File baseImage, final File compareImage) {
        BufferedImage base, compare;
        try {
            base = ImageIO.read(baseImage);
            compare = ImageIO.read(compareImage);
        } catch (IOException e) {
            LOGGER.error("{}", e);
            throw new CartException(CartExceptionType.IO_ERROR, e);
        }

        int width = base.getWidth();
        int height = base.getHeight();

        if ((width != compare.getWidth()) || (height != compare.getHeight())) {
            LOGGER.error("Image dimensions mismatch");
            throw new CartException(CartExceptionType.UNSATISFIED_IMPLICIT_ASSUMPTION, "Image dimensions mismatch");
        }

        long difference = 0;
        BufferedImage resultImage = new BufferedImage(width, height, BufferedImage.TYPE_4BYTE_ABGR);
        for (int y = 0; y < height; y++) {
            for (int x = 0; x < width; x++) {
                try {
                    int basePixel = base.getRGB(x, y);
                    int comparePixel = compare.getRGB(x, y);
                    if (basePixel == comparePixel) {
                        resultImage.setRGB(x, y, base.getRGB(x, y));
                    } else {
                        int baseAlpha = 0xff | basePixel >> 24,
                                baseRed = basePixel >> 16 & 0xff,
                                baseGreen = basePixel >> 8 & 0xff,
                                baseBlue = basePixel & 0xff;

                        int compareAlpha = 0xff | comparePixel >> 24,
                                compareRed = comparePixel >> 16 & 0xff,
                                compareGreen = comparePixel >> 8 & 0xff,
                                compareBlue = comparePixel & 0xff;

                        difference += Math.abs(baseAlpha - compareAlpha);
                        difference += Math.abs(baseRed - compareRed);
                        difference += Math.abs(baseGreen - compareGreen);
                        difference += Math.abs(baseBlue - compareBlue);

                        int modifiedRGB = baseAlpha << 24 | baseRed << 16;
                        resultImage.setRGB(x, y, modifiedRGB);
                    }
                } catch (Exception e) {
                    resultImage.setRGB(x, y, 0x80ff000);
                }
            }
        }

        //red, green and blue
        double total_pixels = width * height * 3;
        double avg_different_pixels = difference / total_pixels;
        // There are 255 values of pixels in total
        double percentage = (avg_different_pixels / 255) * 100;
        if (percentage != 0.0) {
            final String diffImage = "difference.png";
            createImage(resultImage, ImageType.PNG, compareImage.getParent() + File.separator + diffImage);
            LOGGER.error("Difference between images in percentage: {}, Please check [{}] image to see the variations", percentage, diffImage);
            throw new CartException(CartExceptionType.VERIFICATION_FAILED, "Difference between images in percentage: {}, Please check [{}] image to see the variations", percentage, diffImage);
        }
    }

    public void createImage(BufferedImage bufferedImage, ImageType imageType, String filename) {
        try {
            ImageIO.write(bufferedImage, imageType.name(), new File(filename));
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
