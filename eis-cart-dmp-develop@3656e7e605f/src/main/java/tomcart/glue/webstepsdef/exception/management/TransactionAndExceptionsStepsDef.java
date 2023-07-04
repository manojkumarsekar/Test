package tomcart.glue.webstepsdef.exception.management;

import com.eastspring.tom.cart.core.CartBootstrap;
import com.eastspring.tom.cart.core.utl.DataTableUtil;
import com.eastspring.tom.cart.dmp.steps.websteps.exception.management.TransactionAndExceptionsSteps;
import cucumber.api.java8.En;
import io.cucumber.datatable.DataTable;

import java.util.LinkedHashMap;

public class TransactionAndExceptionsStepsDef implements En {

    private TransactionAndExceptionsSteps steps = (TransactionAndExceptionsSteps) CartBootstrap.getBean(TransactionAndExceptionsSteps.class);
    private DataTableUtil dataTableUtil = (DataTableUtil) CartBootstrap.getBean(DataTableUtil.class);

    public TransactionAndExceptionsStepsDef() {
        When("I search for the Transactions And Exceptions with following search criteria", (DataTable dataTable) -> {
            LinkedHashMap<String, String> dataMap = new LinkedHashMap<>(dataTableUtil.getTwoColumnAsMap(dataTable));
            steps.iSearchForTransactionAndExceptions(dataMap);
        });

        Given("I capture Notification Occurrence Count into {string}", (String ncount) -> {
            steps.iCaptureNotificationCountForTransaction(ncount);
        });

        Then("I Resubmit the Transactions And Exceptions", () ->
                steps.iResubmitTransactionAndException()
        );

        Given("I expect Notification Occurrence Count should be {string}", (String expectedNcount) -> {
            steps.iExpectNotificationCountIncreased(expectedNcount);
        });

        Then("I Close Transactions And Exceptions", () ->
                steps.iCloseTransactionAndException()
        );

        Then("I expect Transactions And Exceptions is closed", () ->
                steps.iExpectTransactionAndExceptionClosed()
        );
    }
}
