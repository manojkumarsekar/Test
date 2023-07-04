package tomcart.glue;

import com.eastspring.tom.cart.core.CartBootstrap;
import com.eastspring.tom.cart.core.steps.HooksSteps;
import cucumber.api.Scenario;
import cucumber.api.java.After;
import cucumber.api.java.Before;
import cucumber.api.java8.En;

/**
 * Created by GummarajuM on 24/1/2018.
 */
public class DefaultCucumberHooks implements En {

    private HooksSteps hooksSteps = (HooksSteps) CartBootstrap.getBean(HooksSteps.class);

    //This should execute before the execution
    @Before( order = 0 )
    public void initializeScenario(Scenario scenario) {
        hooksSteps.setScenario(scenario);
        hooksSteps.quitAllScenariosOnFailure();
    }

    //This should execute at the end of execution
    @After( order = 10001 )
    public void tearDown() {
        hooksSteps.tearDownProcess();
    }

    @After (order = 0)
    public void setFeatureFileState() {
        hooksSteps.setSkipScenariosFlagOnFailure();
    }
}
