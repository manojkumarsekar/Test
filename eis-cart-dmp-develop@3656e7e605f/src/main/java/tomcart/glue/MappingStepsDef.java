package tomcart.glue;

import com.eastspring.tom.cart.core.CartBootstrap;
import com.eastspring.tom.cart.core.utl.DataTableUtil;
import com.eastspring.tom.cart.dmp.steps.MappingSteps;
import cucumber.api.java.en.Given;
import cucumber.api.java.en.When;
import io.cucumber.datatable.DataTable;

import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.Map;

import static tomcart.glue.DmpGsWorkflowStepsDef.MAX_POLL_TIME_SECONDS_SMALL;
import static tomcart.glue.DmpGsWorkflowStepsDef.PROCESS_FILES_TEMPLATE_PATH;

public class MappingStepsDef {

    private MappingSteps mapperSteps = (MappingSteps) CartBootstrap.getBean(MappingSteps.class);
    private DataTableUtil dataTableUtil = (DataTableUtil) CartBootstrap.getBean(DataTableUtil.class);

    @When( "I inactivate {string} instrument(s) in {word} database" )
    public void inactivateInstruments(final String instruments, final String dbIdentifier) {
        mapperSteps.inactivateInstruments(instruments, dbIdentifier);
    }

    @When( "I copy below file(s) into dmp inbound folder" )
    public void copyFilesIntoDmpInboundFolder(final DataTable fileTable) {
        mapperSteps.copyFilesIntoDmpInbound(dataTableUtil.getFirstColsAsList(fileTable));
    }

    @When( "I process {string} file with below parameters" )
    public void processFileLoad(String filename, final DataTable workflowParams) {
        mapperSteps.copyFilesIntoDmpInbound(Collections.singletonList(filename));
        mapperSteps.processFileLoad(dataTableUtil.getTwoColumnAsMap(workflowParams), PROCESS_FILES_TEMPLATE_PATH, MAX_POLL_TIME_SECONDS_SMALL);
    }

    @When( "I expect an exception is captured with the following criteria" )
    public void ntelVerification(final DataTable columnValues) {
        final LinkedHashMap<String, String> columnValueMap = new LinkedHashMap<>(dataTableUtil.getTwoColumnAsMap(columnValues));
        mapperSteps.verifyExceptionsInDmp(columnValueMap, 1);
    }

    @When( "I expect {int} exceptions are captured with the following criteria" )
    public void ntelVerification(final Integer recordCount, final DataTable columnValues) {
        final LinkedHashMap<String, String> columnValueMap = new LinkedHashMap<>(dataTableUtil.getTwoColumnAsMap(columnValues));
        mapperSteps.verifyExceptionsInDmp(columnValueMap, recordCount);
    }

    @Given( "Setup BB request reply prerequisites with following details" )
    public void processRequestReplyPrerequisites(DataTable templateParams) {
        final Map<String, String> dataMap = dataTableUtil.getTwoColumnAsMap(templateParams);
        mapperSteps.processRequestReplyPrerequisites(dataMap);

    }


}
