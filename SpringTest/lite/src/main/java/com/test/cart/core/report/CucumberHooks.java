package com.eastspring.qa.cart.core.report;


import com.eastspring.qa.cart.core.CartBootstrap;
import com.eastspring.qa.cart.core.configmanagers.RunConfigManager;
import com.eastspring.qa.cart.core.services.db.DBConnectionManagerSvc;
import com.eastspring.qa.cart.core.services.web.WebDriverManagerSvc;
import io.cucumber.java.*;

import java.io.IOException;


public class CucumberHooks {

    @Before(order = 0)
    public void initializeScenario(Scenario scenario) {
        if (RunConfigManager.TERMINATE_APP_BEFORE_SCENARIO) tearDown();
        CartLogger.setScenario(scenario);
    }

    @AfterStep(order = 0)
    public void tearDownStep(Scenario scenario) {
        CartLogger.autoInsertScreenshot(scenario.isFailed());
    }

    @After(order = 0)
    public void tearDownScenario(Scenario scenario) {
        CartLogger.autoInsertScreenshot(scenario.isFailed());
        if (RunConfigManager.TERMINATE_APP_ON_SCENARIO_FAILURE && scenario.isFailed()) tearDown();
    }

    protected static void tearDown() {
        CartLogger.debug("Initialize all application/connection teardown");
        WebDriverManagerSvc webDriverManagerSvc = (WebDriverManagerSvc) CartBootstrap.getBean(WebDriverManagerSvc.class);
        webDriverManagerSvc.quitAllDrivers();
        DBConnectionManagerSvc dbConnectionManagerSvc = (DBConnectionManagerSvc) CartBootstrap.getBean(DBConnectionManagerSvc.class);
        dbConnectionManagerSvc.closeAllConnections();
        terminateWebDrivers();
        CartLogger.debug("All application/connection teardown is complete");
    }

    private static void terminateWebDrivers() {
        if (System.getProperty("os.name").toUpperCase().contains("WINDOWS")) {
            try {
                Runtime.getRuntime().exec("taskKill /F /fi \"Imagename eq ChromeDriver*\"");
                Runtime.getRuntime().exec("taskKill /F /fi \"Imagename eq IEDriver*\"");
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }
}