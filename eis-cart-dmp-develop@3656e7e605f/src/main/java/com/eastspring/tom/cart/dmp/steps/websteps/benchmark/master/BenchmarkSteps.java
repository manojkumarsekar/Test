package com.eastspring.tom.cart.dmp.steps.websteps.benchmark.master;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import com.eastspring.tom.cart.core.svc.StateSvc;
import com.eastspring.tom.cart.dmp.pages.benchmark.master.BenchmarkPage;
import com.eastspring.tom.cart.dmp.steps.DmpGsPortalSteps;
import com.eastspring.tom.cart.dmp.utl.DmpGsPortalUtl;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.Map;
import java.util.Set;

public class BenchmarkSteps {

    private static final Logger LOGGER = LoggerFactory.getLogger(BenchmarkSteps.class);

    @Autowired
    private BenchmarkPage benchmarkPage;

    @Autowired
    private DmpGsPortalSteps portalSteps;

    @Autowired
    private DmpGsPortalUtl dmpGsPortalUtl;

    @Autowired
    private StateSvc stateSvc;

    public void iCreateBenchMark(Map<String, String> benchMarkDetails) {
        benchmarkPage.navigateToBenchMarkScreen()
                .invokeSetup()
                .fillBenchmarkDetails(benchMarkDetails, false);
    }


    public void iUpdateBenchmark(final String benchmarkName, final Map<String, String> benchMarkDetails) {
        benchmarkPage.searchBenchmark(benchmarkName)
                .fillBenchmarkDetails(benchMarkDetails, true);
    }

    public void iExpectBenchmarkDetailsUpdated(final String benchmarkName, final Map<String, String> benchmarkMap) {
        Map<String, String> benchmarkDetails = benchmarkPage.searchBenchmark(benchmarkName)
                .getBenchmarkDetails();

        Set<String> fields = benchmarkMap.keySet();
        for (String field : fields) {
            String expectedVal = stateSvc.expandVar(benchmarkMap.get(field));
            String actualVal = benchmarkDetails.get(field);
            if (!expectedVal.equals(actualVal)) {
                LOGGER.error("Benchmark Verification failed, Field [{}] Expected Value [{}], but Actual Value [{}]", field, expectedVal, actualVal);
                throw new CartException(CartExceptionType.VERIFICATION_FAILED, "Benchmark Verification failed, Field [{}] Expected Value [{}], but Actual Value [{}]", field, expectedVal, actualVal);
            }
        }
    }

    public void iExpectBenchmarkCreated(final String benchmarkName) {
        if (!benchmarkPage.verifyBenchmarkIsCreated(benchmarkName)) {
            LOGGER.error("Verification failed, Benchmark [{}] is not created", benchmarkName);
            throw new CartException(CartExceptionType.VERIFICATION_FAILED, "Verification failed, Benchmark [{}] is not created", benchmarkName);
        }
    }

}
