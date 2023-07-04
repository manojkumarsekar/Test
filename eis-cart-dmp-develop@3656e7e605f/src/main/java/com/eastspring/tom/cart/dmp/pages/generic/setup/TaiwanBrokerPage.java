package com.eastspring.tom.cart.dmp.pages.generic.setup;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import com.eastspring.tom.cart.core.svc.StateSvc;
import com.eastspring.tom.cart.core.svc.ThreadSvc;
import com.eastspring.tom.cart.core.utl.DateTimeUtil;
import com.eastspring.tom.cart.core.utl.FormatterUtil;
import com.eastspring.tom.cart.dmp.pages.BasePage;
import com.eastspring.tom.cart.dmp.pages.HomePage;
import com.eastspring.tom.cart.dmp.steps.DmpGsPortalSteps;
import com.eastspring.tom.cart.dmp.utl.DmpGsPortalUtl;
import org.h2.util.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;

import static com.eastspring.tom.cart.dmp.mdl.GSUIFields.*;

public class TaiwanBrokerPage extends BasePage {

    private static final Logger LOGGER = LoggerFactory.getLogger(TaiwanBrokerPage.class);

    private static final String TAIWAN_BROKER_SETUP_PORTFOLIO_NAME_VAR = "cssSelector:div[id$='EISPortfolioLongName']";
    private static final String TAIWAN_BROKER_SETUP_ISIN_VAR = "cssSelector:div[id$='ISIN']";
    private static final String TAIWAN_BROKER_SETUP_TAIWAN_BRS_BROKER_CODE_VAR = "cssSelector:div[id$='EISTaiwanBRSBrokerCode']";

    private static final String TAIWAN_BROKER_SETUP_PORTFOLIO_NAME_LOOKUP = "xpath://div[contains(@id,'EISPortfolioLongName')]//div[contains(@class,'gsLookupField')]/div[@role='button']";
    private static final String TAIWAN_BROKER_SETUP_ISIN_LOOKUP = "xpath://div[contains(@id,'ISIN')]//div[contains(@class,'gsLookupField')]/div[@role='button']";
    private static final String TAIWAN_BROKER_SETUP_TAIWAN_BRS_BROKER_CODE_LOOKUP = "xpath://div[contains(@id,'EISTaiwanBRSBrokerCode')]//div[contains(@class,'gsLookupField')]/div[@role='button']";

    private static final String TAIWAN_BROKER_SETUP_PORTFOLIO_NAME_INPUT = TAIWAN_BROKER_SETUP_PORTFOLIO_NAME_VAR + " input";
    private static final String TAIWAN_BROKER_SETUP_ISIN_INPUT = TAIWAN_BROKER_SETUP_ISIN_VAR + " input";
    private static final String TAIWAN_BROKER_SETUP_TAIWAN_BRS_BROKER_CODE_INPUT = TAIWAN_BROKER_SETUP_TAIWAN_BRS_BROKER_CODE_VAR + " input";


    //region Bean Declaration
    @Autowired
    private StateSvc stateSvc;

    @Autowired
    private FormatterUtil formatter;

    @Autowired
    private DmpGsPortalUtl dmpGsPortalUtl;

    @Autowired
    private ThreadSvc threadSvc;

    @Autowired
    private HomePage homePage;

    @Autowired
    private DmpGsPortalSteps dmpGsPortalSteps;

    @Autowired
    private DateTimeUtil dateTimeUtil;
    //endregion


    private boolean mandatoryFlag = true;

    private void setMandatoryFlag(final boolean isAppendModeOn) {
        if (isAppendModeOn) {
            mandatoryFlag = false;
        }
    }

    public TaiwanBrokerPage fillTaiwanBrokerSetup(final LinkedHashMap<String, String> dataMap, boolean isInUpdateMode) {
        this.setMandatoryFlag(isInUpdateMode);

        try {
            if (!StringUtils.isNullOrEmpty(dataMap.get(TBS_PORTFOLIO_NAME))) {
                if (isInUpdateMode && "null".equals(dataMap.get(TBS_PORTFOLIO_NAME))) {
                    dmpGsPortalUtl.clearLookupField(TAIWAN_BROKER_SETUP_PORTFOLIO_NAME_INPUT);
                } else {
                    dmpGsPortalUtl.inputTextInLookUpField(TAIWAN_BROKER_SETUP_PORTFOLIO_NAME_LOOKUP, TBS_GS_PORTFOLIO_CODE, dataMap.get(TBS_PORTFOLIO_NAME), mandatoryFlag);
                }
            }

            if (!StringUtils.isNullOrEmpty(dataMap.get(TBS_ISIN))) {
                if (isInUpdateMode && "null".equals(dataMap.get(TBS_ISIN))) {
                    dmpGsPortalUtl.clearLookupField(TAIWAN_BROKER_SETUP_ISIN_INPUT);
                } else {
                    dmpGsPortalUtl.inputTextInLookUpField(TAIWAN_BROKER_SETUP_ISIN_LOOKUP, TBS_ISIN, dataMap.get(TBS_ISIN), mandatoryFlag);
                }
            }

            if (!StringUtils.isNullOrEmpty(dataMap.get(TBS_TAIWAN_BRS_BROKER_CODE))) {
                if (isInUpdateMode && "null".equals(dataMap.get(TBS_TAIWAN_BRS_BROKER_CODE))) {
                    dmpGsPortalUtl.clearLookupField(TAIWAN_BROKER_SETUP_TAIWAN_BRS_BROKER_CODE_INPUT);
                } else {
                    dmpGsPortalUtl.inputTextInLookUpField(TAIWAN_BROKER_SETUP_TAIWAN_BRS_BROKER_CODE_LOOKUP, dataMap.get(TBS_TAIWAN_BRS_BROKER_CODE), mandatoryFlag);
                }
            }
        } catch (Exception e) {
            LOGGER.error("Exception Occurred while filling Taiwan Broker Details", e);
            throw new CartException(CartExceptionType.IO_ERROR, "Exception Occurred while filling Taiwan Broker Details");
        }
        return this;
    }
}
