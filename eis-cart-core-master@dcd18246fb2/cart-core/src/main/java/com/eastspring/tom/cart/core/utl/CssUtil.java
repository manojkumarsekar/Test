package com.eastspring.tom.cart.core.utl;

import org.openqa.selenium.Point;
import org.openqa.selenium.WebElement;

public class CssUtil {
    public Point getWebElementDimension(WebElement webElement) {
        String cssX = webElement.getCssValue("width");
        String cssY = webElement.getCssValue("height");
        int x = 0;
        int y = 0;

        if(cssX != null) {
            if(cssX.endsWith("px")) {
                x = Integer.parseInt(cssX.substring(0, cssX.length() - 2));
            } else {
                x = Integer.parseInt(cssX);
            }
        }
        if(cssY != null) {
            if(cssY.endsWith("px")) {
                y = Integer.parseInt(cssY.substring(0, cssY.length() - 2));
            } else {
                y = Integer.parseInt(cssY);
            }
        }

        return new Point(x, y);
    }
}
