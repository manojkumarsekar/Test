package tomcart.glue;

import com.eastspring.tom.cart.core.CartBootstrap;
import com.eastspring.tom.cart.core.mdl.HighlightedExcelRequest;
import com.eastspring.tom.cart.core.steps.ReconciliationSteps;
import com.eastspring.tom.cart.core.svc.DataTableSvc;
import com.eastspring.tom.cart.core.svc.ReconciliationSvc;
import com.eastspring.tom.cart.cst.EncodingConstants;
import cucumber.api.java8.En;
import io.cucumber.datatable.DataTable;

public class ReconStepsDef implements En {

    private ReconciliationSteps reconciliationSteps = (ReconciliationSteps) CartBootstrap.getBean(ReconciliationSteps.class);
    private DataTableSvc dataTableSvc = (DataTableSvc) CartBootstrap.getBean(DataTableSvc.class);

    public static final String SOURCE_MONIKER_CPR = "CPR";
    public static final String TARGET_MONIKER_BNP = "BNP";

    public ReconStepsDef() {

        Then("I generate the reconciliation summary report to file {string} using template file {string} at template location {string}", (String reportFile, String templateFile, String templateLocation) -> reconciliationSteps.generateDbReconcileSummaryReport(reportFile, templateLocation, templateFile));

        Then("I export comparison the match results to CSV file {string} and the mismatch results to CSV file {string} and the source surplus rows to CSV file {string} and the target surplus rows to CSV file {string}", (String matchCsvFileFullpath, String mismatchCsvFileFullpath, String sourceSurplusFileFullpath, String targetSurplusFileFullpath) -> reconciliationSteps.exportMatchMismatchToCsvFile(matchCsvFileFullpath, mismatchCsvFileFullpath, sourceSurplusFileFullpath, targetSurplusFileFullpath, 4));

        Then("I produce a highlighted mismatch report in Excel file {string} from CSV file {string}", (String highlightedExcelFileFullpath, String mismatchCsvFileFullpath) -> {
            HighlightedExcelRequest request = new HighlightedExcelRequest();
            request.setCsvFileFullpath(mismatchCsvFileFullpath);
            request.setHighlightedExcelFileFullpath(highlightedExcelFileFullpath);
            request.setSourceName(SOURCE_MONIKER_CPR);
            request.setTargetName(TARGET_MONIKER_BNP);
            request.setMatchName(ReconciliationSvc.MATCH_NAME);
            request.setMatchWithToleranceName(ReconciliationSvc.MATCH_WITH_TOLERANCE_NAME);
            request.setEncoding(EncodingConstants.UTF_8);
            request.setSeparator(',');
            reconciliationSteps.generateMismatchExcelFileFromMismatchCsvFile(request);
        });

        When("I set the global numerical match tolerance to {string}", (String tolerance) -> reconciliationSteps.setGlobalNumericalMatchTolerance(tolerance));

        When("I set the global numerical match tolerance type to {string}", (String toleranceType) -> reconciliationSteps.setGlobalNumericalMatchToleranceType(toleranceType));

        When("I capture current time stamp into variable {string}", (String varName) -> reconciliationSteps.captureCurrentTimestampIntoVar(varName));

        When("I convert the date format for CSV file {string} with column names {string} from format {string} to format {string} to target file {string}",
                (String srcFile, String colNames, String formatSrc, String formatDst, String dstFile) ->
                        reconciliationSteps.convertCsvColsDateFormat(srcFile, colNames, formatSrc, formatDst, dstFile));

        When("I convert the numeric decimal precision for CSV file {string} with column names {string} to {string} decimal point and write it to the target file {string}",
                (String srcFile, String colNames, Integer decimalPoint, String dstFile) ->
                        reconciliationSteps.convertCsvColsNumPrecision(srcFile, colNames, decimalPoint, dstFile));

        When("I remove the string {string} when it occurs at the end of the string for CSV file {string} with column names {string} and write it to the target file {string}", (String postfixToRemove, String srcFile, String colNames, String dstFile) ->
                reconciliationSteps.removePostfixFromCols(postfixToRemove, srcFile, colNames, dstFile));

        Then("I prepare the reconciliation engine", () -> reconciliationSteps.prepareDbReconciliationEngine());

        When("I perform reconciliation between two files with below parameters", (DataTable dataTable) -> {
            reconciliationSteps.performReconciliation(dataTableSvc.getTwoColumnAsMap(dataTable));
        });

        Then("I expect reconciliation should be successful", () -> reconciliationSteps.validateReconciliation());


    }
}
