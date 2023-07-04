package com.eastspring.tom.cart.core.utl;

import com.eastspring.tom.cart.core.CartCoreTestConfig;
import org.junit.Assert;
import org.junit.BeforeClass;
import org.junit.Test;
import org.mockito.Mockito;
import org.openqa.selenium.Point;
import org.openqa.selenium.WebElement;

public class CssUtilTest {
    private CssUtil cssUtil = new CssUtil();

    @BeforeClass
    public static void setUpClass() {
        CartCoreTestConfig.configureLogging(CssUtilTest.class);
    }

    @Test
    public void testGetWebElementDimension_pxHappyPath() throws Exception {
        WebElement webElement = Mockito.mock(WebElement.class);
        Mockito.when(webElement.getCssValue("width")).thenReturn("100px");
        Mockito.when(webElement.getCssValue("height")).thenReturn("64px");
        Point result = cssUtil.getWebElementDimension(webElement);
        Assert.assertNotNull(result);
        Assert.assertEquals(100, result.getX());
        Assert.assertEquals(64, result.getY());
    }

    @Test
    public void testGetWebElementDimension_pxCssXNull() throws Exception {
        WebElement webElement = Mockito.mock(WebElement.class);
        Mockito.when(webElement.getCssValue("width")).thenReturn(null);
        Mockito.when(webElement.getCssValue("height")).thenReturn("64px");
        Point result = cssUtil.getWebElementDimension(webElement);
        Assert.assertNotNull(result);
        Assert.assertEquals(0, result.getX());
        Assert.assertEquals(64, result.getY());
    }
    @Test

    public void testGetWebElementDimension_pxCssYNull() throws Exception {
        WebElement webElement = Mockito.mock(WebElement.class);
        Mockito.when(webElement.getCssValue("width")).thenReturn("100px");
        Mockito.when(webElement.getCssValue("height")).thenReturn(null);
        Point result = cssUtil.getWebElementDimension(webElement);
        Assert.assertNotNull(result);
        Assert.assertEquals(100, result.getX());
        Assert.assertEquals(0, result.getY());
    }

    @Test
    public void testGetWebElementDimension_happyPath() throws Exception {
        WebElement webElement = Mockito.mock(WebElement.class);
        Mockito.when(webElement.getCssValue("width")).thenReturn("100");
        Mockito.when(webElement.getCssValue("height")).thenReturn("64");
        Point result = cssUtil.getWebElementDimension(webElement);
        Assert.assertNotNull(result);
        Assert.assertEquals(100, result.getX());
        Assert.assertEquals(64,result.getY());
    }

    @Test
    public void testGetWebElementDimension_cssXNull() throws Exception {
        WebElement webElement = Mockito.mock(WebElement.class);
        Mockito.when(webElement.getCssValue("width")).thenReturn(null);
        Mockito.when(webElement.getCssValue("height")).thenReturn("64");
        Point result = cssUtil.getWebElementDimension(webElement);
        Assert.assertNotNull(result);
        Assert.assertEquals(0, result.getX());
        Assert.assertEquals(64, result.getY());
    }
    @Test

    public void testGetWebElementDimension_cssYNull() throws Exception {
        WebElement webElement = Mockito.mock(WebElement.class);
        Mockito.when(webElement.getCssValue("width")).thenReturn("100");
        Mockito.when(webElement.getCssValue("height")).thenReturn(null);
        Point result = cssUtil.getWebElementDimension(webElement);
        Assert.assertNotNull(result);
        Assert.assertEquals(100, result.getX());
        Assert.assertEquals(0, result.getY());
    }

    public void testGetWebElementDimension_cssXNull_cssYNull() throws Exception {
        WebElement webElement = Mockito.mock(WebElement.class);
        Mockito.when(webElement.getCssValue("width")).thenReturn(null);
        Mockito.when(webElement.getCssValue("height")).thenReturn(null);
        Point result = cssUtil.getWebElementDimension(webElement);
        Assert.assertNotNull(result);
        Assert.assertEquals(0, result.getX());
        Assert.assertEquals(0, result.getY());
    }
}
