package tomcart.glue;

import com.eastspring.tom.cart.core.CartBootstrap;
import com.eastspring.tom.cart.core.steps.ControlMSteps;
import cucumber.api.java8.En;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class ControlMStepsDef implements En {
    private static final Logger LOGGER = LoggerFactory.getLogger(ControlMStepsDef.class);

    private ControlMSteps controlMSteps = (ControlMSteps) CartBootstrap.getBean(ControlMSteps.class);

    public ControlMStepsDef() {
        Then("I execute the Control-M job {string} in the parent folder {string}", (String jobName, String folder) -> {
            LOGGER.info("executing Control-M job: [{}], folder: [{}]\n", jobName, folder);
            controlMSteps.executeControlMJob(jobName, folder);
        });

        Then("I execute the Control-M smart folder {string} in the parent folder {string}", (String smartFolder, String folder) -> {
            LOGGER.info("executing Control-M job: [{}], folder: [{}]\n", smartFolder, folder);
            controlMSteps.executeControlMSmartFolder(smartFolder, folder);
        });
    }
}
