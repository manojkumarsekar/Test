package com.eastspring.tom.cart.core;

import cucumber.api.CucumberOptions;
import cucumber.api.junit.Cucumber;
import org.junit.AfterClass;
import org.junit.BeforeClass;
import org.junit.runner.RunWith;

@RunWith(Cucumber.class)
@CucumberOptions(
       strict = true,
       monochrome = true,
        features = "src/test",
        tags = "@bdd",
        glue = "tomcart.glue"
)
public class CucumberRunIT {

    @BeforeClass
    public static void beforeClass() {
        System.setProperty("tomcart.basedir", System.getProperty("user.dir"));
    }

    @AfterClass
    public static void afterClass() {
        System.clearProperty("tomcart.basedir");
    }
}
