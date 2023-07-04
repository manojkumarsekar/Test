package stepdefinitions.Solvency;

import com.eastspring.qa.cart.core.exceptions.CartException;
import com.eastspring.qa.cart.core.exceptions.CartExceptionType;
import com.eastspring.qa.cart.core.report.CartLogger;
import com.eastspring.qa.cart.core.utils.core.WorkspaceUtil;
import com.eastspring.qa.cart.core.utils.file.CsvUtil;
import com.eastspring.qa.cart.core.utils.file.FileDirUtil;
import com.eastspring.qa.solvency.lookup.LBURegionCode;
import com.eastspring.qa.solvency.utils.business.LBUFileUtil;
import com.eastspring.qa.solvency.utils.common.DateTimeUtil;
import io.cucumber.java.en.Given;
import io.cucumber.java.en.Then;
import org.springframework.beans.factory.annotation.Autowired;

import java.nio.file.Paths;
import java.text.SimpleDateFormat;
import java.util.*;

public class DataUploadSteps extends BaseSolvencySteps {

    @Autowired
    public FileDirUtil fileDirUtil;


    @Then("the user select the file and upload in Data upload page")
    public void selectFileDropDownList() {
        String portfolioDataUploadName = LbuSteps.testFileName.replaceAll(".csv", "");
        dataUploadPage.lstMonth(portfolioDataUploadName);
        dataUploadPage.clickViewDataButton();
        dataUploadPage.waitUntilUploadButton();
        dataUploadPage.clickUploadButton();
        dataUploadPage.waitForAlertOkButton();
    }

    @Given("^the user expect uploaded ((?:portfolio|position)) data records for (.+) region for ((?:last|current|.*)) month to be present in solvency db$")
    public void compareLBUFileRecordCount(String fileName, String regionCode, String targetMonth) {
        String monthEndTimeStamp = new SimpleDateFormat("dd-MMM-yy").format(DateTimeUtil.getMonthEndDate(targetMonth));
        List<String> testFileRecords = CsvUtil.getRecordsAsStringList(Paths.get(WorkspaceUtil.getExecutionReportsDir(), LbuSteps.testFileName), true);
        CartLogger.info("Number of records in test file [{}]: " + testFileRecords.size(), LbuSteps.testFileName);
        String sqlQueryFileName = LbuSteps.testFileName.replaceAll(".csv", "");
        String query = "select * from Sii_tom_" + fileName + " where FILENAME='" + sqlQueryFileName + "' and Effective_Date='" + monthEndTimeStamp + "'";
        List<HashMap<String, String>> records = gcDatabase.executeSQLQueryForMaps(query);
        LBURegionCode lbuRegionCode = LBUFileUtil.lookupLbuCode(regionCode);
        CartLogger.info("Number of queried records: " + records.size());

        if (LBURegionCode.LBU_984.toString().equals(regionCode)) {
            if (records.size() != testFileRecords.size() - 1) {
                throw new CartException(CartExceptionType.ASSERTION_ERROR, "Record Count is mismatch in---> " + LbuSteps.testFileName + "sql Query is" + query);
            }
        } else if (LBURegionCode.LBU_1090.toString().equals(regionCode)) {
            if (records.size() != testFileRecords.size()) {
                throw new CartException(CartExceptionType.ASSERTION_ERROR, "Record Count is mismatch in---> " + LbuSteps.testFileName + "sql Query is" + query);
            }
        } else {
            throw new CartException(CartExceptionType.INVALID_PARAM, "LBU File Name is mismatch---> " + LbuSteps.testFileName + "sql Query is" + query);
        }
    }

    @Given("^the user expect to compare Data gathering records for ((?:last|current|.*)) to be present (.+) in solvency db$")
    public void compareDataGatheringCount(String targetMonth, String referenceReportName) {
        String yearTimeStamp = new SimpleDateFormat("yyyy").format(DateTimeUtil.getMonthEndDate(targetMonth));
        String monthTimeStamp = new SimpleDateFormat("MMM").format(DateTimeUtil.getMonthEndDate(targetMonth)).toUpperCase();
        List<String> referenceRecords = CsvUtil.getRecordsAsStringList(Paths.get(WorkspaceUtil.getTestDataDir(), referenceReportName), true);
        CartLogger.info("Number of records in test file [{}]: " + referenceRecords.size(), referenceReportName);
        ArrayList<String> identfierNameList;
        ArrayList<String> strAr3 = new ArrayList<String>();
        for (int i = 0; i < referenceRecords.size(); i++) {
            CartLogger.info(referenceRecords.get(i));
            List<String> items1 = Arrays.asList(referenceRecords.get(i).split(","));

            for (int j = 0; j < items1.size(); j++) {

                identfierNameList = new ArrayList<String>();
                identfierNameList.add(items1.get(j));
                CartLogger.info("identfierNameList value ****  " + identfierNameList.toString());
                CartLogger.info("-----   >" + items1.get(j));
                strAr3.addAll(identfierNameList);
                break;
            }
        }
        CartLogger.info("Identifier Name is  " + strAr3);
        String query = "SELECT * FROM SII_T_GHOSTAGINGINSTRUMENT where REPYEAR = '" + yearTimeStamp + "' AND REPMONTH = '" + monthTimeStamp + "' AND IDENTIFIER IN ('" + strAr3.get(0) + "','" + strAr3.get(1) + "','" + strAr3.get(2) + "')";

        List<HashMap<String, String>> records = gcDatabase.executeSQLQueryForMaps(query);
        CartLogger.info("Number of queried records: " + records.size());
        if (referenceRecords.size() != records.size()) {
            throw new CartException(CartExceptionType.ASSERTION_ERROR, "Record Count is mismatch in---> " + referenceReportName + "sql Query is" + query);
        }
    }

}