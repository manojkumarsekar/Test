package com.eastspring.tom.cart.core.labs;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import com.eastspring.tom.cart.core.steps.CartCoreStepsSvcUtlTestConfig;
import com.eastspring.tom.cart.core.utl.PerformanceExcelUtil;
import com.eastspring.tom.cart.core.utl.WorkspaceUtil;
import com.eastspring.tom.cart.cst.EncodingConstants;
import org.apache.commons.io.FileUtils;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

import java.io.File;

@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(classes = {CartCoreStepsSvcUtlTestConfig.class})
public class CprFileExtraction {
    private static final Logger LOGGER = LoggerFactory.getLogger(CprFileExtraction.class);

    @Autowired
    private WorkspaceUtil workspaceUtil;

    @Autowired
    private PerformanceExcelUtil performanceExcelUtil;

    @Test
    public void test() {
//        Given("^I extract the content of ESI CPR Excel file \"([^\"]*)\" columns \"([^\"]*)\" into a CSV file \"([^\"]*)\" having \"([^\"]*)\" as the CSV column names$",
//                (String cprExcelFile, String cprExcelColumns, String csvFile, String csvFileColumns) ->
//                        extractionSteps.extract(cprExcelFile, cprExcelColumns, csvFile, csvFileColumns));

        // TODO parse selective columns
        String workingDir = workspaceUtil.getBaseDir();
        String cprExcelFile = "C:/tomwork/test_repo/cart-gsregression/testdata/abor/ESI CPR Jan 2017.xlsx";
        String csvFile = "C:/tomwork/test_repo/cart-gsregression/testdata/abor/generated.csv";
        String cprExcelFile1 = workingDir + '/' + cprExcelFile;
        String csvFile1 = workingDir + '/' + csvFile;
        LOGGER.info("cprExcelFile1: {}", cprExcelFile1);
        LOGGER.info("csvFile1: {}", csvFile1);
        String sheetName = "All Funds";
        int headersRowToSkip = 10;
        try {
            String extractionResult = performanceExcelUtil.extractAsString(cprExcelFile1, sheetName, headersRowToSkip);
            FileUtils.writeStringToFile(new File(csvFile1), extractionResult, EncodingConstants.UTF_8);
        } catch (Exception e) {
            throw new CartException(CartExceptionType.PROCESSING_FAILED, e);
        }

    }
}
