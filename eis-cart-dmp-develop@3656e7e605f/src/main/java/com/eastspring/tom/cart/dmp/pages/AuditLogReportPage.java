package com.eastspring.tom.cart.dmp.pages;

import com.eastspring.tom.cart.dmp.utl.DmpGsPortalUtl;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.Map;
import java.util.Set;

public class AuditLogReportPage {

    private static final Logger LOGGER = LoggerFactory.getLogger(AuditLogReportPage.class);

    @Autowired
    private HomePage homePage;

    @Autowired
    private DmpGsPortalUtl dmpGsPortalUtl;

    public AuditLogReportPage navigateToAuditLogReport() {
        if ("Audit Log Report".equals(dmpGsPortalUtl.getActiveScreenName())) {
            return this;
        }
        LOGGER.debug("Navigating to Industry Classification Set Screen");
        homePage.clickMenuDropdown()
                .selectMenu("AuditLog")
                .selectMenu("Audit Log Report");
        homePage.verifyGSTabDisplayed("Audit Log Report");
        return this;
    }

    public AuditLogReportPage searchAuditLog(final Map<String, String> map) {
        final Set<String> columns = map.keySet();
        for (String column : columns) {
            dmpGsPortalUtl.filterTable(column, map.get(column), false);
        }
        return this;
    }
}
