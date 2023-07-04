package tomcart.glue;

import com.eastspring.tom.cart.core.CartBootstrap;
import com.eastspring.tom.cart.core.steps.PdfValidationSteps;
import com.eastspring.tom.cart.core.svc.DataTableSvc;
import cucumber.api.java8.En;
import io.cucumber.datatable.DataTable;

import java.util.List;
import java.util.Map;

public class PdfStepsDef implements En {

    private PdfValidationSteps pdfValidationSteps = (PdfValidationSteps) CartBootstrap.getBean(PdfValidationSteps.class);
    private DataTableSvc dataTableSvc = (DataTableSvc) CartBootstrap.getBean(DataTableSvc.class);

    public PdfStepsDef() {

        When("I load pdf file {string} for processing", (String filepath) -> pdfValidationSteps.processPdfFile(filepath));

        Then("I consider below content to be excluded in pdf comparison with TEXT mode", (DataTable exclusionData) -> {
            List<String> exclusionList = dataTableSvc.getFirstColsAsList(exclusionData);
            pdfValidationSteps.configureExclusions(exclusionList);
        });

        Then("I expect pdf file should contains below values", (DataTable valueTable) -> {
            List<String> valuesList = dataTableSvc.getFirstColsAsList(valueTable);
            pdfValidationSteps.verifyValuesInPdf(valuesList);
        });

        Then("I expect pdf file should contains below values with given expected number of occurrences", (DataTable valuesCntTable) -> {
            Map<String, String> valueCntMap = dataTableSvc.getTwoColumnAsMap(valuesCntTable);
            pdfValidationSteps.verifyValueOccurrencesInPdf(valueCntMap);
        });

        Then("I expect page {int} of pdf file should contains below values in given coordinates", (Integer pageNumber, DataTable valueCoordinatesTable) -> {
            Map<String, String> valueCoordinatesMap = dataTableSvc.getTwoColumnAsMap(valueCoordinatesTable);
            pdfValidationSteps.verifyValueCoordinatesInPdf(pageNumber, valueCoordinatesMap);
        });

        Then("I expect pdf file {string} should be identical to the one which is under processing", (String filepath) -> {
            pdfValidationSteps.comparePdf(pdfValidationSteps.getPdfFile().getAbsoluteFile().toString(), filepath);
        });

        Then("I expect below pdf files should be identical", (DataTable filesTable) -> {
            List<String> files = dataTableSvc.getFirstColsAsList(filesTable);
            pdfValidationSteps.comparePdf(files.get(0), files.get(1));
        });

        Then("I expect page {int} of below pdf files should be identical", (Integer pageNumber, DataTable filesTable) -> {
            List<String> files = dataTableSvc.getFirstColsAsList(filesTable);
            pdfValidationSteps.comparePdfByPageByText(files.get(0), files.get(1), pageNumber);
        });

        Then("I extract pdf file page {int} data into variable {string}", (Integer pageNumber, String targetVar) -> {
            pdfValidationSteps.assignPdfTextToVar(pageNumber, targetVar);
        });
    }
}
