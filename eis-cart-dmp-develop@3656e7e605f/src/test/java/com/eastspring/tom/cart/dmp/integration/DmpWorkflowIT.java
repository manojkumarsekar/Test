package com.eastspring.tom.cart.dmp.integration;

import com.eastspring.tom.cart.core.svc.StateSvc;
import com.eastspring.tom.cart.dmp.steps.DmpGsWorkflowSteps;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

import java.util.Map;
import java.util.Objects;

@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(classes = {CartDmpStepsSvcUtlConfig.class})
public class DmpWorkflowIT {

    @Autowired
    private StateSvc stateSvc;

    @Autowired
    private DmpGsWorkflowSteps steps;

    @Test
    public void test() {
        steps.setTemplateParam("abc", "123");
        steps.setTemplateParam("def", "456");
        Map<String, String> valueMap = stateSvc.getValueStringMapFromPrefix(DmpGsWorkflowSteps.GSWF_TEMPLATE_PARAM_PREFIX, true);
        System.out.println(Objects.toString(valueMap));
    }
}
