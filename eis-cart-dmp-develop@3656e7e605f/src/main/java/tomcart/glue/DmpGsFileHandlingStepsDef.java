package tomcart.glue;

import com.eastspring.tom.cart.core.CartBootstrap;
import com.eastspring.tom.cart.core.svc.DataTableSvc;
import com.eastspring.tom.cart.core.utl.DataTableUtil;
import com.eastspring.tom.cart.dmp.steps.DmpGsWorkflowSteps;
import com.eastspring.tom.cart.dmp.utl.ReconFileHandler;
import cucumber.api.java.en.Given;
import cucumber.api.java.en.Then;
import cucumber.api.java.en.When;
import cucumber.api.java8.En;
import io.cucumber.datatable.DataTable;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import static com.eastspring.tom.cart.dmp.utl.mdl.ReconType.*;

public class DmpGsFileHandlingStepsDef implements En {

    private DmpGsWorkflowSteps wfSteps = (DmpGsWorkflowSteps) CartBootstrap.getBean(DmpGsWorkflowSteps.class);
    private DataTableUtil dataTableUtil = (DataTableUtil) CartBootstrap.getBean(DataTableUtil.class);
    private ReconFileHandler reconFileHandler = (ReconFileHandler) CartBootstrap.getBean(ReconFileHandler.class);
    private DataTableSvc dataTableSvc = (DataTableSvc) CartBootstrap.getBean(DataTableSvc.class);

    private static final String ACTUAL_FILE = "ActualFile";
    private static final String EXPECTED_FILE = "ExpectedFile";
    private static final String SHEET_INDEX = "SheetIndex";
    private static final String FILE1 = "File1";
    private static final String FILE2 = "File2";


    //Deprecated steps are putting in Lamda style. So, these are not visible to user for intellisense.
    public DmpGsFileHandlingStepsDef() {

        Then("I expect reconciliation between generated (CSV|PSV|XML) file {string} and reference (CSV|PSV|XML) file {string} should be successful and exceptions to be written to {string} file", (String generatedFile, String referenceFile, String exceptionsFile) -> {
            wfSteps.invokeReconciliations(SRC_TARGET_EXACT_MATCH,
                    reconFileHandler.setFiles(generatedFile, referenceFile, exceptionsFile));
        });

        Then("I expect all records in file {string} should exist in file {string} with same order and exceptions to be written to {string} file", (String file1, String file2, String exceptionsFile) -> {
            wfSteps.invokeReconciliations(SRC_TARGET_EXACT_MATCH_WITH_ORDER,
                    reconFileHandler.setFiles(file1, file2, exceptionsFile));
        });

        Then("I expect each record in file {string} should exist in file {string} and exceptions to be written to {string} file", (String file1, String file2, String exceptionsFile) -> {
            wfSteps.invokeReconciliations(SRC_ALL_MATCH,
                    reconFileHandler.setFiles(file1, file2, exceptionsFile));
        });

        Then("I expect each record in file {string} should not exist in file {string} and exceptions to be written to {string} file", (String file1, String file2, String exceptionsFile) -> {
            wfSteps.invokeReconciliations(SRC_NONE_MATCH,
                    reconFileHandler.setFiles(file1, file2, exceptionsFile));
        });
    }

    @When("I extract below values for row {int} from PSV file {string} in local folder {string} and assign to variables:")
    public void extractValuesFromPSVFile(Integer dataRow, String inputFile, String localDir, DataTable fieldsNVars) {
        wfSteps.extractColumnValueFromPSVFileAndAssignToVariables(dataRow, inputFile, localDir, fieldsNVars);
    }

    @Given("I extract below values for row {int} from PSV file {string} in local folder {string} with reference to {string} column and assign to variables:")
    public void extractColumnValueFromPSVFileAndAssignToVariables(Integer dataRow, String inputFile, String localDir, String refColumn, DataTable fieldsNVars) {
        wfSteps.extractColumnValueFromPSVFileAndAssignToVariables(dataRow, inputFile, localDir, fieldsNVars, refColumn);
    }

    @Given("I extract below values for row {int} from BBGPSV file {string} in local folder {string} and assign to variables:")
    public void extractColumnValueFromBBGPSVFileAndAssignToVariables(Integer dataRow, String inputFile, String localDir, DataTable fieldsNVars) {
        wfSteps.extractColumnValueFromBBGPSVFileAndAssignToVariables(dataRow, inputFile, localDir, fieldsNVars);
    }

    @Given("I extract below values for row {int} from CSV file {string} in local folder {string} with reference to {string} column and assign to variables:")
    public void extractColumnValueFromCSVFileAndAssignToVariables(Integer dataRow, String inputFile, String localDir, String refColumn, DataTable fieldsNVars) {
        wfSteps.extractColumnValueFromCSVFileAndAssignToVariables(dataRow, inputFile, localDir, fieldsNVars, refColumn);
    }

    @Given("I extract below values for row {int} from EXCEL file {string} in local folder {string} and assign to variables:")
    public void extractColumnValueFromEXCELFileAndAssignToVariables(Integer dataRow, String inputFile, String localDir, DataTable fieldsNVars) {
        wfSteps.extractColumnValueFromEXCELFileAndAssignToVariables(dataRow, inputFile, localDir, fieldsNVars);
    }

    //New Step for EXACT MATCH
    @Then("I expect reconciliation should be successful between given (CSV|PSV|OUT|XML|QQQ) files")
    public void exactMatch(DataTable dataTable) {
        final Map<String, String> map = dataTableUtil.getTwoColumnAsMap(dataTable);

        wfSteps.invokeReconciliations(SRC_TARGET_EXACT_MATCH,
                reconFileHandler.setFiles(map.get(ACTUAL_FILE), map.get(EXPECTED_FILE)));
    }

    @When("I expect reconciliation should be successful between given EXCEL files")
    public void compareExcelFiles(DataTable dataTable) {
        final Map<String, String> map = dataTableUtil.getTwoColumnAsMap(dataTable);

        wfSteps.compareExcelFiles(map.get(ACTUAL_FILE), map.get(EXPECTED_FILE),
                Integer.valueOf(map.getOrDefault(SHEET_INDEX, "0")));
    }

    //New step for EXACT MATCH with ORDER
    @Then("I expect reconciliation should be successful between given (CSV|PSV|OUT|XML|QQQ) files including order")
    public void exactMatchWithOrder(DataTable dataTable) {
        final Map<String, String> map = dataTableUtil.getTwoColumnAsMap(dataTable);

        wfSteps.invokeReconciliations(SRC_TARGET_EXACT_MATCH_WITH_ORDER,
                reconFileHandler.setFiles(map.get(ACTUAL_FILE), map.get(EXPECTED_FILE)));
    }

    //New Step for ALL FROM ACTUAL SHOULD MATCH IN EXPECTED
    @Then("I expect all records from file1 of type (CSV|PSV|OUT|XML|QQQ) exists in file2")
    public void allMatch(DataTable dataTable) {
        final Map<String, String> map = dataTableUtil.getTwoColumnAsMap(dataTable);

        wfSteps.invokeReconciliations(SRC_ALL_MATCH,
                reconFileHandler.setFiles(map.get(FILE1), map.get(FILE2)));
    }

    //New Step for NONE FROM ACTUAL SHOULD MATCH IN EXPECTED
    @Then("I expect none of the records from file1 of type (CSV|PSV|OUT|XML|QQQ) exists in file2")
    public void noneMatch(DataTable dataTable) {
        final Map<String, String> map = dataTableUtil.getTwoColumnAsMap(dataTable);

        wfSteps.invokeReconciliations(SRC_NONE_MATCH,
                reconFileHandler.setFiles(map.get(FILE1), map.get(FILE2)));
    }

    @Then("I expect file {string} should have below columns")
    public void verifyColumnAvailable(String filename, DataTable columnsTable) {
        wfSteps.verifyColumnAvailable(filename, dataTableUtil.getFirstColsAsList(columnsTable));
    }

    @Then("I expect column {string} value to be {string} where column {string} value is {string} in CSV file {string}")
    public void verifyColumnValueFromCSV(String colToVerify, String expectedVal, String refCol, String refVal, String file) {
        wfSteps.verifyColumnValueFromCSV(colToVerify, expectedVal, refCol, refVal, file);
    }

    @Then("I expect column {string} value to be {string} where columns values are as below in CSV file {string}")
    public void verifyColumnValueFromCSV(String colToVerify, String expectedVal, String file, DataTable columnValPair) {
        wfSteps.verifyColumnValueFromCSV(colToVerify, expectedVal, dataTableUtil.getTwoColumnAsMap(columnValPair), file);
    }

    @Then("I expect column {string} values in the CSV file {string} should be (with pattern ){string}")
    public void iExpectColumnValuesShouldBeAsPerCondition(String column, String file, String valOrPattern) {
        wfSteps.iExpectColumnValuesOfCSVFileShouldBeAsPerCondition(column, file, valOrPattern, true);
    }

    @Then("I expect column {string} values in the CSV file {string} should not be (with pattern ){string}")
    public void iExpectColumnValuesShouldNotBeAsPerCondition(String column, String file, String valOrPattern) {
        wfSteps.iExpectColumnValuesOfCSVFileShouldBeAsPerCondition(column, file, valOrPattern, false);
    }

    @Then("I expect duplicate records not found in the file {string}")
    public void iExpectThereAreNoDuplicatesRecordsInFile(String filePath) {
        wfSteps.iExpectThereAreNoDuplicatesRecordsInFile(filePath);
    }

    @Then("I expect occurrences of string {string} in file {string} equals to {int}")
    public void verifyNoOfOccurrencesOfStringInFile(String stringToSearch, String filePath, Integer expectedCnt) {
        wfSteps.verifyNoOfOccurrencesOfStringInFile(stringToSearch, filePath, expectedCnt);
    }

    @When("I create input file {string} using template {string} with below codes from location {string}")
    public void createFileFromTemplate(String inputFile, String templateFile, String parentFolder, DataTable varCodeTable) {
        wfSteps.changePatternsInTemplateAndCreateNewFile(inputFile, templateFile, parentFolder, dataTableUtil.getTwoColumnAsMap(varCodeTable));
    }

    @When("I create input file {string} using template {string} from location {string}")
    public void createFileFromTemplate(String inputFile, String templateFile, String parentFolder) {
        wfSteps.changePatternsInTemplateAndCreateNewFile(inputFile, templateFile, parentFolder, new HashMap<>());
    }

    @When("I exclude below columns from (CSV|PSV|EXCEL) file while doing reconciliations")
    public void excludeColumn(DataTable columns) {
        reconFileHandler.setExcludedColumns(dataTableSvc.getFirstColsAsList(columns));
    }

    @When( "I exclude below column indices from (CSV|PSV|EXCEL) file while doing reconciliations" )
    public void excludeColumnIndices(DataTable columns) {
        final List<Integer> indices = dataTableSvc.getFirstColsAsList(columns)
                .stream()
                .map(Integer::valueOf)
                .map(i -> i - 1) //i-1 is because user will be passing 1st column instead of 0th column
                .collect(Collectors.toList());
        reconFileHandler.setExcludedColumnsIndices(indices);
    }

    //New Step for verifying sorting order in the QQQ files
    @Then("I expect sell records are sorted after buy records in the file {string} of type QQQ")
    public void isRecordsSorted(String file) {
        wfSteps.iExpectRecordsAreSorted(file);
    }


}
