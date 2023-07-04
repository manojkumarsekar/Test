package com.eastspring.tom.cart.dmp.steps.websteps.generic.setup;

import com.eastspring.tom.cart.dmp.pages.generic.setup.GroupTreasuryConfigPage;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.Map;

public class GroupTreasuryConfigSteps {

    private static final Logger LOGGER = LoggerFactory.getLogger(GroupTreasuryConfigSteps.class);

    @Autowired
    private GroupTreasuryConfigPage groupTreasuryConfigPage;


    public void iAddGroupTreasuryConfigDetails(Map<String, String> dataMap) {
        groupTreasuryConfigPage.navigateToGroupTreasury()
                .invokeSetup()
                .fillGroupTreasuryConfigDetails(dataMap, false);
    }

    public void iOpenGroupTreasuryConfig(String otherCounterPartyId) {
        groupTreasuryConfigPage.navigateToGroupTreasury()
                .openGroupTreasuryAccount(otherCounterPartyId);
    }

    public void iUpdatedGroupTreasuryConfigDetails(final Map<String, String> map) {
        groupTreasuryConfigPage.fillGroupTreasuryConfigDetails(map, true);
    }

}
