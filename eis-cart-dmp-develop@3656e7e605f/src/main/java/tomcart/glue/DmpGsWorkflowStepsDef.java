package tomcart.glue;


import com.eastspring.tom.cart.core.CartBootstrap;
import com.eastspring.tom.cart.core.utl.DataTableUtil;
import com.eastspring.tom.cart.dmp.steps.DmpGsWorkflowSteps;
import cucumber.api.java8.En;
import io.cucumber.datatable.DataTable;

import java.util.List;
import java.util.Map;

import static com.eastspring.tom.cart.constant.BrsApiConstants.*;

/**
 * <p>This class contains the definition for the steps related to the GS Worfklow.</p>
 *
 * @author Daniel Baktiar
 * @since 2017-09
 */
public class DmpGsWorkflowStepsDef implements En {

    private DmpGsWorkflowSteps wfSteps = (DmpGsWorkflowSteps) CartBootstrap.getBean(DmpGsWorkflowSteps.class);
    private DataTableUtil dataTableUtil = (DataTableUtil) CartBootstrap.getBean(DataTableUtil.class);

    public static final String PROCESS_FILES_TEMPLATE_PATH = "tests/test-data/dmp-interfaces/Process_Files/template/request.xmlt";

    private static final String PROCESS_FILES_BRS_API_TEMPLATE_PATH = "tests/test-data/dmp-interfaces/EIS_ProcessFiles_CallAPI/template/request.xmlt";
    private static final String PROCESS_FILES_BRS_API_REPROCESS_TH_TRADES_PATH = "tests/test-data/dmp-interfaces/EIS_CallBRSAPI_ReprocessTHTrades/template/request.xmlt";
    private static final String PROCESS_FILES_BRS_API_ETD_REQUEST_REPLY = "tests/test-data/dmp-interfaces/EIS_BRSETDTradeRequestReply/template/request.xmlt";

    public static final String FILE_TRANSFER_TEMPLATE_PATH = "tests/test-data/intf-specs/gswf/template/EIS_FileTransfer/request.xmlt";
    private static final String GOLDENPRICE_CALC_TEMPLATE_PATH = "tests/test-data/intf-specs/gswf/template/EIS_PricingProcessConsolidated/request.xmlt";
    public static final String ASYNC_RESPONSE_FILE_PATH = "testout/dmp-interfaces/asyncResponse.xml";
    private static final String PUBLISHING_WRAPPER_TEMPLATE_PATH = "tests/test-data/dmp-interfaces/Process_Files/template/PublishingWrapper/request.xmlt";
    private static final String PUBLISH_DOCUMENT_TEMPLATE_PATH = "tests/test-data/dmp-interfaces/Process_Files/template/PublishDocument/request.xmlt";
    private static final String PUBLISHING_WRAPPER_DWH_TEMPLATE_PATH = "tests/test-data/dmp-interfaces/Process_Files/template/PublishingWrapper_Dwh/request.xmlt";
    private static final String PUBLISHING_WRAPPER_GSO_DWH_TEMPLATE_PATH = "tests/test-data/dmp-interfaces/Process_Files/template/PublishingWrapper_GSO_Dwh/request.xmlt";
    private static final String LOAD_PUBLISH_EXCEPTIONS = "tests/test-data/intf-specs/gswf/template/EIS_LoadFiles_PublishExceptions/request1.xmlt";
    private static final String DERIVE_ESI_STALE_PRICES = "tests/test-data/intf-specs/gswf/template/EIS_DeriveESIStalePrices/request.xmlt";
    private static final String REUTERS_DSS_WRAPPER_TEMPLATE_PATH = "tests/test-data/intf-specs/gswf/template/EIS_ReutersDSSWrapper/request.xmlt";
    private static final String BB_PER_SECURITY_TEMPLATE_PATH = "tests/test-data/intf-specs/gswf/template/EIS_BBPerSecurity/request.xmlt";
    private static final String REFRESH_SOI_TEMPLATE_PATH = "tests/test-data/intf-specs/gswf/template/EIS_RefreshSOI/request.xmlt";
    private static final String CONVERT_DOS_TO_UNIX_TEMPLATE_PATH = "tests/test-data/intf-specs/gswf/template/EIS_ConvertDos2Unix/request.xmlt";
    private static final String CONVERT_XLSX_TO_CSV_LOAD_TEMPLATE_PATH = "tests/test-data/intf-specs/gswf/template/EIS_ConvertXLSXtoCSVandLoad/request_wrapper.xmlt";
    private static final String ICE_PER_SECURITY_TEMPLATE_PATH = "tests/test-data/intf-specs/gswf/template/EIS_ICEPerSecurity/request.xmlt";

    public static final Integer MAX_POLL_TIME_SECONDS_SMALL = 60;
    private static final Integer MAX_POLL_TIME_SECONDS_HIGH = 600;
    private static final Integer MAX_POLL_TIME_SECONDS_MEDIUM = 180;

    public static final String EMAIL_FILES_TEMPLATE_PATH = "tests/test-data/email/template/";
    public static final String EMAIL_FILES_BODY_PATH = "tests/test-data/email";


    public DmpGsWorkflowStepsDef() {
        Given("I set the workflow template parameter {string} to {string}", (String paramName, String paramValue) ->
                wfSteps.setTemplateParam(paramName, paramValue)
        );

        Given("I clear all predefined workflow template parameters", () ->
                wfSteps.clearPredefinedTemplateParams()
        );

        Given("I set the workflow template parameter {string} to", (String paramName, String multiLineParamValue) ->
                wfSteps.setTemplateParam(paramName, multiLineParamValue)
        );

        Given("I set the DMP workflow web service endpoint to named configuration {string}", (String wsConfigName) ->
                wfSteps.setWebServiceConfigName(wsConfigName)
        );

        When("I send a web service request using template file {string} and save the response to file {string}", (String templateFile, String responseFile) ->
                wfSteps.sendWebServiceRequestUsingTemplateFile(templateFile, responseFile)
        );

        Then("I send a web service request using an xml file {string} and save the response to file {string}", (String xmlFile, String responseFile) ->
                // Write code here that turns the phrase above into concrete actions
                wfSteps.sendWebServiceRequestUsingXMLFile(xmlFile, responseFile)
        );

        Given("I send \"Process Files Directory Asynchron\" request with below template parameters with template {string} and " +
                "save the response to file {string}", (String templateFile, String responseFile, DataTable templateParams) ->
                wfSteps.processWorkFlowRequest(templateFile, responseFile, templateParams)
        );

        Given("I send \"Publishing Wrapper\" request with below template parameters with template {string} and " +
                "save the response to file {string}", (String templateFile, String responseFile, DataTable templateParams) ->
                wfSteps.processWorkFlowRequest(templateFile, responseFile, templateParams)
        );


        Given("I process files with below parameters and wait for the job to be completed", (DataTable templateParams) ->
                wfSteps.processWorkFlowRequestAndWaitTillCompletion(PROCESS_FILES_TEMPLATE_PATH, ASYNC_RESPONSE_FILE_PATH, templateParams, MAX_POLL_TIME_SECONDS_SMALL)
        );

        Given("I process Brs Api RequestReply workflow with below parameters and wait for the job to be completed", (DataTable templateParams) ->
                wfSteps.processWorkFlowRequestAndWaitTillCompletion(PROCESS_FILES_BRS_API_TEMPLATE_PATH, ASYNC_RESPONSE_FILE_PATH, templateParams, MAX_POLL_TIME_SECONDS_SMALL)
        );

        Given("I process Brs Api ReprocessTHTrades workflow with below parameters and wait for the job to be completed", (DataTable templateParams) ->
                wfSteps.processWorkFlowRequestAndWaitTillCompletion(PROCESS_FILES_BRS_API_REPROCESS_TH_TRADES_PATH, ASYNC_RESPONSE_FILE_PATH, templateParams, MAX_POLL_TIME_SECONDS_MEDIUM)
        );

        Given("I process file transfer with below parameters and wait for the job to be completed", (DataTable templateParams) ->
                wfSteps.processWorkFlowRequestAndWaitTillCompletion(FILE_TRANSFER_TEMPLATE_PATH, ASYNC_RESPONSE_FILE_PATH, templateParams, MAX_POLL_TIME_SECONDS_SMALL)
        );

        Given("I process publishing wrapper with below parameters and wait for the job to be completed", (DataTable templateParams) ->
                wfSteps.processWorkFlowRequestAndWaitTillCompletion(PUBLISHING_WRAPPER_TEMPLATE_PATH, ASYNC_RESPONSE_FILE_PATH, templateParams, MAX_POLL_TIME_SECONDS_HIGH)
        );

        Given("I process publish document workflow with below parameters and wait for the job to be completed", (DataTable templateParams) ->
                wfSteps.processWorkFlowRequestAndWaitTillCompletion(PUBLISH_DOCUMENT_TEMPLATE_PATH, ASYNC_RESPONSE_FILE_PATH, templateParams, MAX_POLL_TIME_SECONDS_HIGH)
        );

        Given("I process Load files and publish exceptions with below parameters and wait for the job to be completed", (DataTable templateParams) ->
                wfSteps.processWorkFlowRequestAndWaitTillCompletion(LOAD_PUBLISH_EXCEPTIONS, ASYNC_RESPONSE_FILE_PATH, templateParams, MAX_POLL_TIME_SECONDS_HIGH)
        );

        Given("I process DWH publishing wrapper with below parameters and wait for the job to be completed", (DataTable templateParams) ->
                wfSteps.processWorkFlowRequestAndWaitTillCompletion(PUBLISHING_WRAPPER_DWH_TEMPLATE_PATH, ASYNC_RESPONSE_FILE_PATH, templateParams, MAX_POLL_TIME_SECONDS_HIGH)
        );

        Given("I process GSO_DWH publishing wrapper with below parameters and wait for the job to be completed", (DataTable templateParams) ->
                wfSteps.processWorkFlowRequestAndWaitTillCompletion(PUBLISHING_WRAPPER_GSO_DWH_TEMPLATE_PATH, ASYNC_RESPONSE_FILE_PATH, templateParams, MAX_POLL_TIME_SECONDS_HIGH)
        );

        Given("I process ICEPerSecurity workflow with below parameters and wait for the job to be completed", (DataTable templateParams) ->
                wfSteps.processWorkFlowRequestAndWaitTillCompletion(ICE_PER_SECURITY_TEMPLATE_PATH, ASYNC_RESPONSE_FILE_PATH, templateParams, MAX_POLL_TIME_SECONDS_HIGH)
        );

        Given("I process ReutersDSSWrapper workflow with below parameters and wait for the job to be completed", (DataTable templateParams) ->
                wfSteps.processWorkFlowRequestAndWaitTillCompletion(REUTERS_DSS_WRAPPER_TEMPLATE_PATH, ASYNC_RESPONSE_FILE_PATH, templateParams, MAX_POLL_TIME_SECONDS_HIGH)
        );

        Given("I process BBPerSecurity workflow with below parameters and wait for the job to be completed", (DataTable templateParams) ->
                wfSteps.processWorkFlowRequestAndWaitTillCompletion(BB_PER_SECURITY_TEMPLATE_PATH, ASYNC_RESPONSE_FILE_PATH, templateParams, MAX_POLL_TIME_SECONDS_HIGH)
        );

        Given("I process RefreshSOI workflow with below parameters and wait for the job to be completed", (DataTable templateParams) ->
                wfSteps.processWorkFlowRequestAndWaitTillCompletion(REFRESH_SOI_TEMPLATE_PATH, ASYNC_RESPONSE_FILE_PATH, templateParams, MAX_POLL_TIME_SECONDS_HIGH)
        );

        Given("I process ConvertDos2Unix workflow with below parameters and wait for the job to be completed", (DataTable templateParams) ->
                wfSteps.processWorkFlowRequestAndWaitTillCompletion(CONVERT_DOS_TO_UNIX_TEMPLATE_PATH, ASYNC_RESPONSE_FILE_PATH, templateParams, MAX_POLL_TIME_SECONDS_HIGH)
        );

        Given("I process DeriveESIStalePrices workflow with below parameters", (DataTable templateParams) ->
                wfSteps.processWorkFlowRequestAndWaitTillCompletion(DERIVE_ESI_STALE_PRICES, ASYNC_RESPONSE_FILE_PATH, templateParams, MAX_POLL_TIME_SECONDS_MEDIUM)
        );

        Given("I process ConvertXlsxToCsvLoad workflow with below parameters and wait for the job to be completed", (DataTable templateParams) ->
                wfSteps.processWorkFlowRequestAndWaitTillCompletion(CONVERT_XLSX_TO_CSV_LOAD_TEMPLATE_PATH, ASYNC_RESPONSE_FILE_PATH, templateParams, MAX_POLL_TIME_SECONDS_MEDIUM)
        );

        Given("I process Goldenprice calculation with below parameters and wait for the job to be completed", (DataTable templateParams) ->
                wfSteps.processWorkFlowRequestAndWaitTillCompletion(GOLDENPRICE_CALC_TEMPLATE_PATH, ASYNC_RESPONSE_FILE_PATH, templateParams, MAX_POLL_TIME_SECONDS_HIGH)
        );

        Given("I Post Order using BRS API with below details", (DataTable orderParams) -> {
            wfSteps.postOrderUsingBRSApi(BRS_API_TEMPLATES_RELATIVE_PATH, BRS_API_BODY_RELATIVE_PATH, orderParams);
        });

        Given("I retrieve below order details for order number {string} and assign into same variables", (String orderNumber, DataTable orderRetrieveParams) -> {
            wfSteps.retrieveOrderUsingBRSApi(BRS_API_BODY_RELATIVE_PATH, orderNumber, orderRetrieveParams);
        });

        Given("I process the workflow template file {string} with below parameters and wait for the job to be completed", (String templateFile, DataTable templateParams) -> {
            wfSteps.processWorkFlowRequestAndWaitTillCompletion(templateFile, ASYNC_RESPONSE_FILE_PATH, templateParams, MAX_POLL_TIME_SECONDS_MEDIUM);
        });

        When("I send research report email for category {string} to common mail box with below details", (String emailBodyTemplate, DataTable emailParams) -> {
            wfSteps.sendEmailUsingTemplate(EMAIL_FILES_TEMPLATE_PATH + emailBodyTemplate, EMAIL_FILES_BODY_PATH, emailParams);
        });

        Then("(I expect workflow is processed in DMP with ){word} record count as {string}", (String columnName, String recordCount) -> {
            wfSteps.checkProcessWorkFlowRecordCount(columnName, recordCount);
        });

        Given("I process Brs ETD RequestReply workflow with below parameters and wait for the job to be completed", (DataTable templateParams) ->
                wfSteps.processWorkFlowRequestAndWaitTillCompletion(PROCESS_FILES_BRS_API_ETD_REQUEST_REPLY, ASYNC_RESPONSE_FILE_PATH, templateParams, MAX_POLL_TIME_SECONDS_MEDIUM)
        );

        Given("I retrieve below trade details for BRS trade reference {string} into same variables", (String tradeReference, DataTable tradeDetails) -> {
            final List<String> list = dataTableUtil.getFirstColsAsList(tradeDetails);
            wfSteps.retrieveTradeUsingBRSApi(tradeReference, list);
        });

        Given("I place BRS Trade with following trade economics", (DataTable tradeParamsTable) -> {
            final Map<String, String> tradeEconomics = dataTableUtil.getTwoColumnAsMap(tradeParamsTable);
            wfSteps.placeTradeUsingBrsApi(BRS_DEFAULT_TRADE_API_BODY_TEMPLATE_FILE, tradeEconomics);
        });

        Given("I place BRS Trade using the template {string} with following trade economics", (String postBodyTemplate, DataTable tradeParamsTable) -> {
            final Map<String, String> tradeEconomics = dataTableUtil.getTwoColumnAsMap(tradeParamsTable);
            wfSteps.placeTradeUsingBrsApi(postBodyTemplate, tradeEconomics);
        });
    }
}

