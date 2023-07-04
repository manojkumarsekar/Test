package com.eastspring.tom.cart.dmp.pages;

import com.eastspring.tom.cart.dmp.utl.DmpGsPortalUtl;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

@SuppressWarnings("unchecked")
public abstract class BasePage {

    private static final Logger LOGGER = LoggerFactory.getLogger(BasePage.class);

    @Autowired
    private DmpGsPortalUtl dmpGsPortalUtl;

    @Autowired
    private HomePage homePage;

    public void invokeSetup() {
        dmpGsPortalUtl.invokeSetUpScreen(null, null, null);
    }

    public void navigateToScreen(final String parentMenu, final String childMenu) {
        LOGGER.debug("Navigating to [{}]:[{}]", parentMenu, childMenu);
        homePage.clickMenuDropdown()
                .selectMenu(parentMenu)
                .selectMenu(childMenu);
    }

}


