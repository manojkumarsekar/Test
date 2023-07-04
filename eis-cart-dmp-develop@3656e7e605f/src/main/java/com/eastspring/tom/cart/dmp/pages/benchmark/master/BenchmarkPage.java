package com.eastspring.tom.cart.dmp.pages.benchmark.master;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import com.eastspring.tom.cart.core.svc.StateSvc;
import com.eastspring.tom.cart.core.svc.ThreadSvc;
import com.eastspring.tom.cart.core.svc.WebTaskSvc;
import com.eastspring.tom.cart.core.utl.DateTimeUtil;
import com.eastspring.tom.cart.core.utl.FormatterUtil;
import com.eastspring.tom.cart.dmp.pages.HomePage;
import com.eastspring.tom.cart.dmp.steps.DmpGsPortalSteps;
import com.eastspring.tom.cart.dmp.utl.DmpGsPortalUtl;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.HashMap;
import java.util.Map;

import static com.eastspring.tom.cart.dmp.mdl.GSUIFields.*;

public class BenchmarkPage {

    private static final Logger LOGGER = LoggerFactory.getLogger(BenchmarkPage.class);

    public static final String VALUE = "value";
    public static final String ENTER = "ENTER";

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
    private DateTimeUtil dateTimeUtil;

    @Autowired
    private DmpGsPortalSteps dmpGsPortalSteps;

    @Autowired
    private WebTaskSvc webTaskSvc;


    public static final String BENCHMARK_EIS_BENCHMARKMARK_LOCATOR = "xpath://*[@id='Benchmark.EISBenchmarkDefinition.EISBenchmarkName']//input";
    public static final String BENCHMARK_OFFICIAL_BENCHMARKMARK_LOCATOR = "xpath://*[@id='Benchmark.EISBenchmarkDefinition.EISBenchmarkDesc']//textarea";
    public static final String BENCHMARK_CURRENCY_LOCATOR = "xpath://*[@id='Benchmark.EISBenchmarkDefinition.EISBenchmarkCurrency']//input";
    public static final String BENCHMARK_HEGDEINDICATOR_LOCATOR = "xpath://*[@id='Benchmark.EISBenchmarkDefinition.EISBenchmarkHedgeInd']//input";
    public static final String BENCHMARK_REBALANCE_FREQUENCY_LOCATOR = "xpath://*[@id='Benchmark.EISBenchmarkDefinition.EISBenchmarkRebalanceFrequency']//input";
    public static final String BENCHMARK_BENCHMARKMARK_LEVELACCESS_LOCATOR = "xpath://*[@id='Benchmark.EISBenchmarkDefinition.EISBenchmarkBenchmarkLevelAccess']//input";
    public static final String BENCHMARK_BENCHMARKMARK_PROVIDERNAME_LOCATOR = "xpath://*[@id='Benchmark.EISBenchmarkDefinition.EISBenchmarkProviderName']//input";
    public static final String BENCHMARK_BENCHMARKMARK_CATEGORY_LOCATOR = "xpath://*[@id='Benchmark.EISBenchmarkDefinition.EISBenchmarkCategory']//input";
    public static final String BENCHMARK_CRTSCODE_LOCATOR = "xpath://*[@id='Benchmark.EISBenchmarkDefinition.EISBenchmarkCRTSCode']//input";
    public static final String BENCHMARK_PERFORMANCE_FLAG_LOCATOR = "xpath://*[@id='Benchmark.EISBenchmarkDefinition.BNPPerformanceBenchmarkFlag']//input";

    private boolean mandatoryFlag = true;

    private void setMandatoryFlag(final boolean isInUpdateMode) {
        if (isInUpdateMode) {
            mandatoryFlag = false;
        }
    }

    public BenchmarkPage navigateToBenchMarkScreen() {
        LOGGER.debug("Navigating to Benchmark Screen");
        homePage.clickMenuDropdown()
                .selectMenu("Benchmark Master")
                .selectMenu("Benchmark");
        homePage.verifyGSTabDisplayed("Benchmark");
        return this;
    }

    public BenchmarkPage searchBenchmark(final String benchmarkName) {
        homePage.globalSearchAndWaitTillSuccess(benchmarkName, "Benchmark", 120);
        return this;
    }

    public BenchmarkPage invokeSetup() {
        dmpGsPortalUtl.invokeSetUpScreen(null, null, null);
        return this;
    }

    public BenchmarkPage fillBenchmarkDetails(Map<String, String> map, final boolean isInUpdateMode) {
        try {
            setMandatoryFlag(isInUpdateMode);
            dmpGsPortalUtl.inputText(BENCHMARK_EIS_BENCHMARKMARK_LOCATOR, map.get(BENCHMARK_NAME), ENTER, mandatoryFlag);
            dmpGsPortalUtl.inputText(BENCHMARK_OFFICIAL_BENCHMARKMARK_LOCATOR, map.get(BENCHMARK_OFFICIAL_NAME), null, mandatoryFlag);
            dmpGsPortalUtl.inputText(BENCHMARK_CURRENCY_LOCATOR, map.get(BENCHMARK_CCY), ENTER, mandatoryFlag);
            dmpGsPortalUtl.inputText(BENCHMARK_HEGDEINDICATOR_LOCATOR, map.get(BENCHMARK_HEDGE_INDICATOR), ENTER, false);
            dmpGsPortalUtl.inputText(BENCHMARK_REBALANCE_FREQUENCY_LOCATOR, map.get(BENCHMARK_REBAL_FREQUENCY), ENTER, false);
            dmpGsPortalUtl.inputText(BENCHMARK_BENCHMARKMARK_LEVELACCESS_LOCATOR, map.get(BENCHMARK_LEVEL_ACCESS), ENTER, mandatoryFlag);
            dmpGsPortalUtl.inputText(BENCHMARK_BENCHMARKMARK_PROVIDERNAME_LOCATOR, map.get(BENCHMARK_PROVIDER_NAME), ENTER, false);
            dmpGsPortalUtl.inputText(BENCHMARK_BENCHMARKMARK_CATEGORY_LOCATOR, map.get(BENCHMARK_CATEGORY), ENTER, mandatoryFlag);
            dmpGsPortalUtl.inputText(BENCHMARK_CRTSCODE_LOCATOR, map.get(BENCHMARK_CRTS_CODE), ENTER, false);
            dmpGsPortalUtl.inputText(BENCHMARK_PERFORMANCE_FLAG_LOCATOR, map.getOrDefault(BENCHMARK_PERFORMANCE_FLAG, "N - No"), ENTER, mandatoryFlag);
            return this;
        } catch (Exception e) {
            LOGGER.error("Exception Occurred while filling Benchmark Details", e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Exception Occurred while filling Benchmark Details");
        }
    }

    public Map<String, String> getBenchmarkDetails() {
        Map<String, String> dataMap = new HashMap<>();

        dataMap.put(BENCHMARK_NAME, webTaskSvc.getWebElementAttribute(BENCHMARK_EIS_BENCHMARKMARK_LOCATOR, VALUE));
        dataMap.put(BENCHMARK_OFFICIAL_NAME, webTaskSvc.getWebElementAttribute(BENCHMARK_OFFICIAL_BENCHMARKMARK_LOCATOR, VALUE));
        dataMap.put(BENCHMARK_CCY, webTaskSvc.getWebElementAttribute(BENCHMARK_CURRENCY_LOCATOR, VALUE));
        dataMap.put(BENCHMARK_HEDGE_INDICATOR, webTaskSvc.getWebElementAttribute(BENCHMARK_HEGDEINDICATOR_LOCATOR, VALUE));
        dataMap.put(BENCHMARK_REBAL_FREQUENCY, webTaskSvc.getWebElementAttribute(BENCHMARK_REBALANCE_FREQUENCY_LOCATOR, VALUE));
        dataMap.put(BENCHMARK_LEVEL_ACCESS, webTaskSvc.getWebElementAttribute(BENCHMARK_BENCHMARKMARK_LEVELACCESS_LOCATOR, VALUE));
        dataMap.put(BENCHMARK_PROVIDER_NAME, webTaskSvc.getWebElementAttribute(BENCHMARK_BENCHMARKMARK_PROVIDERNAME_LOCATOR, VALUE));
        dataMap.put(BENCHMARK_CATEGORY, webTaskSvc.getWebElementAttribute(BENCHMARK_BENCHMARKMARK_CATEGORY_LOCATOR, VALUE));
        dataMap.put(BENCHMARK_CRTS_CODE, webTaskSvc.getWebElementAttribute(BENCHMARK_CRTSCODE_LOCATOR, VALUE));

        return dataMap;
    }

    public boolean verifyBenchmarkIsCreated(final String benchmarkName) {
        this.searchBenchmark(benchmarkName);
        boolean searchRecordAvailable = dmpGsPortalUtl.isSearchRecordAvailable(benchmarkName);
        dmpGsPortalSteps.closeActiveGsTab();
        return searchRecordAvailable;
    }
}