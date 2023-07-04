package com.eastspring.tom.cart.dmp.steps;

import com.eastspring.tom.cart.core.steps.HostSteps;
import com.eastspring.tom.cart.core.svc.StateSvc;
import com.eastspring.tom.cart.dmp.integration.CartDmpStepsSvcUtlConfig;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(classes = {CartDmpStepsSvcUtlConfig.class})
public class DmpTradeLifeCycleStepsIT {

    @Autowired
    private DmpTradeLifeCycleSteps steps;

    @Autowired
    private HostSteps hostSteps;

    @Autowired
    private DmpGsWorkflowSteps dmpGsWorkflowSteps;

    @Autowired
    private StateSvc stateSvc;


}
